import ComposableArchitecture
import Foundation

@Reducer
struct MainChat {
    @ObservableState
    struct State: Equatable {
        var selectedConversation: Conversation? = nil
        var messages: [Message] = []
        var draftMessage = ""
        var isSending = false
        var selectedModel: ComposerModelOption = .gpt54
        var reasoningLevel: ComposerReasoningLevel = .high
        var speedMode: ComposerSpeedMode = .standard
        var contextUsage = ComposerContextUsage(usedTokens: 107_000, tokenLimit: 258_000)
        var executionScope: ComposerExecutionScope = .local
        var toolPolicy: ComposerToolPolicy = .review
        var selectedBranch: ComposerBranch = .main
    }

    @CasePathable
    enum Action: Equatable {
        case sidebarToggleTapped
        case sidebarDismissed
        case newConversationTapped
        case draftMessageChanged(String)
        case sendMessageTapped
        case messageSent(Message)
        case sendFailed(String)
        case loadMessages(UUID)
        case messagesLoaded([Message])
        case composerModelSelected(ComposerModelOption)
        case reasoningLevelSelected(ComposerReasoningLevel)
        case speedModeSelected(ComposerSpeedMode)
        case executionScopeSelected(ComposerExecutionScope)
        case toolPolicySelected(ComposerToolPolicy)
        case branchSelected(ComposerBranch)
        case attachmentTapped
        case microphoneTapped
        case contextNotesTapped
        case conversationSelected(Conversation)
        case conversationCreated(Conversation)
    }

    @Dependency(\.chatPersistence) var chatPersistence

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sidebarToggleTapped, .sidebarDismissed, .newConversationTapped:
                return .none

            case .draftMessageChanged(let text):
                state.draftMessage = text
                return .none

            case .sendMessageTapped:
                let content = state.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty else {
                    state.draftMessage = ""
                    return .none
                }
                state.draftMessage = ""
                state.isSending = true
                let message = Message.text(TextMessage(role: .user, content: content))

                if let conversation = state.selectedConversation {
                    let conversationId = conversation.id
                    return .run { send in
                        do {
                            try await chatPersistence.saveMessage(message, conversationId)
                            await send(.messageSent(message))
                        } catch {
                            await send(.sendFailed(error.localizedDescription))
                        }
                    }
                } else {
                    let title = content.count > 30 ? String(content.prefix(30)) + "..." : content
                    let selectedModel = state.selectedModel
                    let newConversation = Conversation(
                        title: title,
                        modelID: selectedModel.rawValue,
                        providerID: selectedModel.providerID
                    )
                    return .run { send in
                        do {
                            let saved = try await chatPersistence.createConversation(newConversation)
                            await send(.conversationCreated(saved))
                            try await chatPersistence.saveMessage(message, saved.id)
                            await send(.messageSent(message))
                        } catch {
                            await send(.sendFailed(error.localizedDescription))
                        }
                    }
                }

            case .messageSent(let message):
                state.isSending = false
                state.messages.append(message)
                return .none

            case .sendFailed:
                state.isSending = false
                return .none

            case .loadMessages(let conversationId):
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversationId)
                    await send(.messagesLoaded(messages))
                }

            case .messagesLoaded(let messages):
                state.messages = messages
                return .none

            case .conversationSelected(let conversation):
                state.selectedConversation = conversation
                state.messages = []
                if let model = ComposerModelOption.resolve(modelID: conversation.modelID) {
                    state.selectedModel = model
                }
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversation.id)
                    await send(.messagesLoaded(messages))
                }

            case .conversationCreated(let conversation):
                state.selectedConversation = conversation
                return .none

            case .composerModelSelected(let model):
                state.selectedModel = model
                if !model.availableSpeedModes.contains(state.speedMode) {
                    state.speedMode = model.availableSpeedModes.first ?? .standard
                }
                return .none

            case .reasoningLevelSelected(let level):
                state.reasoningLevel = level
                return .none

            case .speedModeSelected(let mode):
                guard state.selectedModel.availableSpeedModes.contains(mode) else {
                    return .none
                }
                state.speedMode = mode
                return .none

            case .executionScopeSelected(let scope):
                state.executionScope = scope
                return .none

            case .toolPolicySelected(let policy):
                state.toolPolicy = policy
                return .none

            case .branchSelected(let branch):
                state.selectedBranch = branch
                return .none

            case .attachmentTapped, .microphoneTapped, .contextNotesTapped:
                return .none
            }
        }
    }
}
