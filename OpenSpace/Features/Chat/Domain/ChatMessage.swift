import Foundation

enum ChatMessage: Equatable, Identifiable, Sendable {
    case text(ChatTextMessage)
    case thinking(ChatThinkingMessage)
    case toolCall(ChatToolCallMessage)
    case toolResult(ChatToolResultMessage)
    case subagentLink(ChatSubagentLinkMessage)
    case attachment(ChatAttachmentMessage)
    case system(ChatSystemMessage)

    private var payload: any ChatMessagePayload {
        switch self {
        case let .text(message):
            return message
        case let .thinking(message):
            return message
        case let .toolCall(message):
            return message
        case let .toolResult(message):
            return message
        case let .subagentLink(message):
            return message
        case let .attachment(message):
            return message
        case let .system(message):
            return message
        }
    }

    var id: UUID { payload.id }
    var role: ChatMessageRole { payload.role }
    var timestamp: Date { payload.timestamp }
}
