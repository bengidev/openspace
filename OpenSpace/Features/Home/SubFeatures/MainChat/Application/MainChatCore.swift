import ComposableArchitecture
import Foundation

@Reducer
struct MainChat {
    @Dependency(ChatPersistenceClient.self) private var chatPersistence
    @Dependency(\.date.now) private var now
    @Dependency(\.uuid) private var uuid

    @ObservableState
    struct State: Equatable {
        var selectedConversation: ChatConversation?
        var messages: [ChatMessage] = []
        var draftMessage = ""
        var isSending = false
        var threadEngine = ThreadEngine.State()
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
        case messageSent(ChatMessage)
        case sendFailed(String)
        case loadMessages(UUID)
        case messagesLoaded([ChatMessage])
        case threadEngine(ThreadEngine.Action)
        case composerModelSelected(ComposerModelOption)
        case reasoningLevelSelected(ComposerReasoningLevel)
        case speedModeSelected(ComposerSpeedMode)
        case executionScopeSelected(ComposerExecutionScope)
        case toolPolicySelected(ComposerToolPolicy)
        case branchSelected(ComposerBranch)
        case attachmentTapped
        case microphoneTapped
        case contextNotesTapped
        case conversationSelected(ChatConversation)
        case conversationCreated(ChatConversation)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.threadEngine, action: \.threadEngine) {
            ThreadEngine()
        }

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

                let timestamp = now
                let message = ChatMessage.text(
                    ChatTextMessage(
                        id: uuid(),
                        role: .user,
                        content: content,
                        timestamp: timestamp
                    )
                )

                if let conversation = state.selectedConversation {
                    return .run { [message] send in
                        do {
                            try await chatPersistence.saveMessage(message, conversation.id)
                            await send(.messageSent(message))
                            await send(.threadEngine(.userMessageSent(message)))
                        } catch {
                            await send(.sendFailed(error.localizedDescription))
                        }
                    }
                }

                let selectedModel = state.selectedModel
                let newConversation = ChatConversation(
                    id: uuid(),
                    title: Self.conversationTitle(for: content),
                    createdAt: timestamp,
                    updatedAt: timestamp,
                    modelID: selectedModel.rawValue,
                    providerID: selectedModel.providerID
                )

                return .run { [message, newConversation] send in
                    do {
                        let savedConversation = try await chatPersistence.createConversation(newConversation)
                        await send(.conversationCreated(savedConversation))
                        try await chatPersistence.saveMessage(message, savedConversation.id)
                        await send(.messageSent(message))
                        await send(.threadEngine(.userMessageSent(message)))
                    } catch {
                        await send(.sendFailed(error.localizedDescription))
                    }
                }

            case .messageSent(let message):
                if var conversation = state.selectedConversation {
                    conversation.updatedAt = message.timestamp
                    state.selectedConversation = conversation
                }
                return .none

            case .sendFailed:
                state.isSending = false
                state.threadEngine.streamingStatus = .idle
                return .none

            case .loadMessages(let conversationID):
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversationID)
                    await send(.messagesLoaded(messages))
                }

            case .messagesLoaded(let messages):
                state.messages = messages
                state.threadEngine.messages = messages
                return .none

            case .conversationSelected(let conversation):
                state.selectedConversation = conversation
                state.messages = []
                state.threadEngine.messages = []
                state.threadEngine.streamingStatus = .idle
                state.threadEngine.currentPartialText = ""
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

            case .threadEngine:
                state.messages = state.threadEngine.messages
                state.isSending = state.threadEngine.streamingStatus == .running
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

    private static func conversationTitle(for content: String) -> String {
        if content.count > 30 {
            return String(content.prefix(30)) + "..."
        }
        return content
    }
}
