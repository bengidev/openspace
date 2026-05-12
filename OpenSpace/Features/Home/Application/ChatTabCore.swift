import ComposableArchitecture
import SwiftUI

@Reducer
struct ChatTab {
    @ObservableState
    struct State: Equatable {
        var conversationList = ConversationListState()
        var isSidebarVisible = false
        var messages: [Message] = []
        var draftMessage = ""
        var isSending = false
        var showSettings = false
    }

    @CasePathable
    enum Action: Equatable {
        case conversationList(ConversationListAction)
        case sidebarToggleTapped
        case sidebarDismissed
        case draftMessageChanged(String)
        case sendMessageTapped
        case messageSent(Message)
        case newConversationTapped
        case settingsTapped
        case dismissSettings
        case loadMessages(UUID)
        case messagesLoaded([Message])
    }

    @Dependency(\.chatPersistence) var chatPersistence

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

            case .draftMessageChanged(let text):
                state.draftMessage = text
                return .none

            case .sendMessageTapped:
                guard !state.draftMessage.isEmpty else { return .none }
                let content = state.draftMessage
                state.draftMessage = ""
                state.isSending = true
                let message = Message.text(TextMessage(role: .user, content: content))

                if let conversation = state.conversationList.selectedConversation {
                    let conversationId = conversation.id
                    return .run { send in
                        try await chatPersistence.saveMessage(message, conversationId)
                        await send(.messageSent(message))
                    }
                } else {
                    let title = content.count > 30 ? String(content.prefix(30)) + "..." : content
                    let newConversation = Conversation(title: title)
                    return .run { send in
                        let saved = try await chatPersistence.createConversation(newConversation)
                        try await chatPersistence.saveMessage(message, saved.id)
                        await send(.conversationList(.conversationCreated(saved)))
                        await send(.messageSent(message))
                    }
                }

            case .messageSent(let message):
                state.isSending = false
                state.messages.append(message)
                return .none

            case .newConversationTapped:
                state.conversationList.selectedConversation = nil
                state.messages = []
                state.isSidebarVisible = false
                return .none

            case .settingsTapped:
                state.showSettings = true
                state.isSidebarVisible = false
                return .none

            case .dismissSettings:
                state.showSettings = false
                return .none

            case .loadMessages(let conversationId):
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversationId)
                    await send(.messagesLoaded(messages))
                }

            case .messagesLoaded(let messages):
                state.messages = messages
                return .none

            case .conversationList(.conversationSelected(let conversation)):
                state.messages = []
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversation.id)
                    await send(.messagesLoaded(messages))
                }

            case .conversationList:
                return .none
            }
        }
    }
}
