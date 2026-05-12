import ComposableArchitecture
import Foundation

@ObservableState
struct ConversationListState: Equatable {
    var conversations: [Conversation] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var selectedConversation: Conversation?
    var errorMessage: String?
}

@CasePathable
enum ConversationListAction: Equatable {
    case onAppear
    case conversationsLoaded([Conversation])
    case createConversationTapped
    case conversationCreated(Conversation)
    case deleteConversationTapped(UUID)
    case conversationDeleted(UUID)
    case searchQueryChanged(String)
    case searchResultsLoaded([Conversation])
    case conversationSelected(Conversation)
    case deselectConversation
    case clearError
}

struct ConversationList: Reducer {
    @Dependency(\.chatPersistence) var chatPersistence

    var body: some Reducer<ConversationListState, ConversationListAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let conversations = try await chatPersistence.fetchConversations()
                    await send(.conversationsLoaded(conversations))
                }

            case .conversationsLoaded(let conversations):
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
                state.isLoading = true
                return .run { send in
                    let results = try await chatPersistence.searchConversations(query)
                    await send(.searchResultsLoaded(results))
                }

            case .searchResultsLoaded(let results):
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
