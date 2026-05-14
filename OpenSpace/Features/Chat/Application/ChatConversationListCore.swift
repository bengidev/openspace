import ComposableArchitecture
import Foundation

@Reducer
struct ChatConversationList {
    @Dependency(ChatPersistenceClient.self) private var chatPersistence
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.date.now) private var now
    @Dependency(\.uuid) private var uuid

    @ObservableState
    struct State: Equatable {
        var conversations: [ChatConversation] = []
        var searchQuery = ""
        var isLoading = false
        var selectedConversation: ChatConversation?
        var errorMessage: String?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case conversationsLoaded([ChatConversation])
        case createConversationTapped
        case conversationCreated(ChatConversation)
        case deleteConversationTapped(UUID)
        case conversationDeleted(UUID)
        case searchQueryChanged(String)
        case searchResultsLoaded(query: String, [ChatConversation])
        case conversationSelected(ChatConversation)
        case deselectConversation
        case persistenceFailed(String)
        case clearError
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let conversations = try await chatPersistence.fetchConversations()
                        await send(.conversationsLoaded(conversations))
                    } catch {
                        await send(.persistenceFailed(error.localizedDescription))
                    }
                }

            case .conversationsLoaded(let conversations):
                guard state.searchQuery.isEmpty else {
                    return .none
                }
                state.isLoading = false
                state.conversations = conversations
                return .none

            case .createConversationTapped:
                let createdAt = now
                let newConversation = ChatConversation(
                    id: uuid(),
                    title: "New Chat",
                    createdAt: createdAt,
                    updatedAt: createdAt
                )
                return .run { send in
                    do {
                        let savedConversation = try await chatPersistence.createConversation(newConversation)
                        await send(.conversationCreated(savedConversation))
                    } catch {
                        await send(.persistenceFailed(error.localizedDescription))
                    }
                }

            case .conversationCreated(let conversation):
                state.conversations.removeAll { $0.id == conversation.id }
                state.conversations.insert(conversation, at: 0)
                state.selectedConversation = conversation
                state.errorMessage = nil
                return .none

            case .deleteConversationTapped(let id):
                return .run { send in
                    do {
                        try await chatPersistence.deleteConversation(id)
                        await send(.conversationDeleted(id))
                    } catch {
                        await send(.persistenceFailed(error.localizedDescription))
                    }
                }

            case .conversationDeleted(let id):
                state.conversations.removeAll { $0.id == id }
                if state.selectedConversation?.id == id {
                    state.selectedConversation = nil
                }
                return .none

            case .searchQueryChanged(let query):
                state.searchQuery = query
                state.isLoading = true
                state.errorMessage = nil
                return .run { [clock] send in
                    do {
                        try await clock.sleep(for: .milliseconds(query.isEmpty ? 120 : 220))
                        let results: [ChatConversation]
                        if query.isEmpty {
                            results = try await chatPersistence.fetchConversations()
                        } else {
                            results = try await chatPersistence.searchConversations(query)
                        }
                        await send(.searchResultsLoaded(query: query, results))
                    } catch {
                        await send(.persistenceFailed(error.localizedDescription))
                    }
                }
                .cancellable(id: "ChatConversationList.search", cancelInFlight: true)

            case .searchResultsLoaded(let query, let results):
                guard query == state.searchQuery else {
                    return .none
                }
                state.isLoading = false
                state.conversations = results
                return .none

            case .conversationSelected(let conversation):
                state.selectedConversation = conversation
                return .none

            case .deselectConversation:
                state.selectedConversation = nil
                return .none

            case .persistenceFailed(let message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .clearError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
