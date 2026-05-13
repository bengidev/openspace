import ComposableArchitecture
import Foundation

struct ConversationList: Reducer {
    @Dependency(\.continuousClock) private var clock
    @ObservableState
    struct State: Equatable {
        var conversations: [Conversation] = []
        var searchQuery: String = ""
        var isLoading: Bool = false
        var selectedConversation: Conversation?
        var errorMessage: String?
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case conversationsLoaded([Conversation])
        case createConversationTapped
        case conversationCreated(Conversation)
        case deleteConversationTapped(UUID)
        case conversationDeleted(UUID)
        case searchQueryChanged(String)
        case searchResultsLoaded(query: String, [Conversation])
        case conversationSelected(Conversation)
        case deselectConversation
        case clearError
    }

    @Dependency(\.chatPersistence) var chatPersistence

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let conversations = try await chatPersistence.fetchConversations()
                    await send(.conversationsLoaded(conversations))
                }

            case .conversationsLoaded(let conversations):
                guard state.searchQuery.isEmpty else {
                    return .none
                }
                state.isLoading = false
                state.conversations = conversations
                return .none

            case .createConversationTapped:
                let newConversation = Conversation(title: "New Chat")
                return .run { send in
                    let saved = try await chatPersistence.createConversation(newConversation)
                    await send(.conversationCreated(saved))
                }

            case .conversationCreated(let conversation):
                state.conversations.insert(conversation, at: 0)
                state.selectedConversation = conversation
                return .none

            case .deleteConversationTapped(let id):
                return .run { send in
                    try await chatPersistence.deleteConversation(id)
                    await send(.conversationDeleted(id))
                }

            case .conversationDeleted(let id):
                state.conversations.removeAll { $0.id == id }
                if state.selectedConversation?.id == id {
                    state.selectedConversation = nil
                }
                return .none

            case .searchQueryChanged(let query):
                state.searchQuery = query
                return .run { [clock] send in
                    try await clock.sleep(for: .milliseconds(query.isEmpty ? 120 : 220))
                    let results: [Conversation]
                    if query.isEmpty {
                        results = try await chatPersistence.fetchConversations()
                    } else {
                        results = try await chatPersistence.searchConversations(query)
                    }
                    await send(.searchResultsLoaded(query: query, results))
                }
                .cancellable(id: "conversationList.search", cancelInFlight: true)

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

            case .clearError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
