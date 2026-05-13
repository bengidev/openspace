import ComposableArchitecture
import Foundation

@Reducer
struct SideStory {
    @ObservableState
    struct State: Equatable {
        var conversationList = ConversationList.State()
        var isSidebarVisible = false
    }

    @CasePathable
    enum Action: Equatable {
        case conversationList(ConversationList.Action)
        case sidebarToggleTapped
        case sidebarDismissed
        case newConversationTapped
        case settingsTapped
        case conversationCreated(Conversation)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.conversationList, action: \.conversationList) {
            ConversationList()
        }

        Reduce { state, action in
            switch action {
            case .sidebarToggleTapped:
                state.isSidebarVisible.toggle()
                return .none

            case .sidebarDismissed:
                state.isSidebarVisible = false
                return .none

            case .newConversationTapped:
                state.conversationList.selectedConversation = nil
                state.isSidebarVisible = false
                return .none

            case .settingsTapped:
                state.isSidebarVisible = false
                return .none

            case .conversationCreated(let conversation):
                state.conversationList.conversations.insert(conversation, at: 0)
                state.conversationList.selectedConversation = conversation
                return .none

            case .conversationList:
                return .none
            }
        }
    }
}
