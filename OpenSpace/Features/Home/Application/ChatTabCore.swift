import ComposableArchitecture
import Foundation
import SwiftUI

enum ComposerModelOption: String, CaseIterable, Equatable, Identifiable, Sendable {
    case gpt54 = "gpt-5.4"
    case gpt55 = "gpt-5.5"
    case local = "local"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gpt54:
            return "GPT-5.4"
        case .gpt55:
            return "GPT-5.5"
        case .local:
            return "Local"
        }
    }

    var providerID: String? {
        switch self {
        case .gpt54, .gpt55:
            return "openai"
        case .local:
            return "local"
        }
    }

    static func resolve(modelID: String?) -> ComposerModelOption? {
        guard let modelID else { return nil }
        return allCases.first { $0.rawValue == modelID || $0.title == modelID }
    }
}

enum ComposerReasoningLevel: String, CaseIterable, Equatable, Identifiable, Sendable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

enum ComposerExecutionScope: String, CaseIterable, Equatable, Identifiable, Sendable {
    case local
    case hybrid
    case cloud

    var id: String { rawValue }

    var title: String {
        switch self {
        case .local:
            return "Local"
        case .hybrid:
            return "Hybrid"
        case .cloud:
            return "Cloud"
        }
    }
}

enum ComposerToolPolicy: String, CaseIterable, Equatable, Identifiable, Sendable {
    case review
    case auto
    case disabled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .review:
            return "Review"
        case .auto:
            return "Auto"
        case .disabled:
            return "Off"
        }
    }
}

enum ComposerBranch: String, CaseIterable, Equatable, Identifiable, Sendable {
    case main
    case plan
    case lab

    var id: String { rawValue }

    var title: String { rawValue }
}

@Reducer
struct ChatTab {
    @ObservableState
    struct State: Equatable {
        var conversationList = ConversationList.State()
        var isSidebarVisible = false
        var messages: [Message] = []
        var draftMessage = ""
        var isSending = false
        var showSettings = false
        var selectedModel: ComposerModelOption = .gpt54
        var reasoningLevel: ComposerReasoningLevel = .high
        var executionScope: ComposerExecutionScope = .local
        var toolPolicy: ComposerToolPolicy = .review
        var selectedBranch: ComposerBranch = .main
    }

    @CasePathable
    enum Action: Equatable {
        case conversationList(ConversationList.Action)
        case sidebarToggleTapped
        case sidebarDismissed
        case draftMessageChanged(String)
        case sendMessageTapped
        case messageSent(Message)
        case sendFailed(String)
        case newConversationTapped
        case settingsTapped
        case dismissSettings
        case loadMessages(UUID)
        case messagesLoaded([Message])
        case composerModelSelected(ComposerModelOption)
        case reasoningLevelSelected(ComposerReasoningLevel)
        case executionScopeSelected(ComposerExecutionScope)
        case toolPolicySelected(ComposerToolPolicy)
        case branchSelected(ComposerBranch)
        case attachmentTapped
        case microphoneTapped
        case contextNotesTapped
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
                let content = state.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty else {
                    state.draftMessage = ""
                    return .none
                }
                state.draftMessage = ""
                state.isSending = true
                let message = Message.text(TextMessage(role: .user, content: content))

                if let conversation = state.conversationList.selectedConversation {
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
                            try await chatPersistence.saveMessage(message, saved.id)
                            await send(.conversationList(.conversationCreated(saved)))
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
                if let model = ComposerModelOption.resolve(modelID: conversation.modelID) {
                    state.selectedModel = model
                }
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversation.id)
                    await send(.messagesLoaded(messages))
                }

            case .conversationList:
                return .none

            case .composerModelSelected(let model):
                state.selectedModel = model
                return .none

            case .reasoningLevelSelected(let level):
                state.reasoningLevel = level
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
