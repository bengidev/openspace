import Foundation

extension ChatMessage {
    nonisolated var apiMessageDictionary: [String: String] {
        switch self {
        case .text(let m):
            return ["role": m.role.rawValue, "content": m.content]
        case .thinking(let m):
            return ["role": ChatMessageRole.assistant.rawValue, "content": m.content]
        case .system(let m):
            return ["role": ChatMessageRole.system.rawValue, "content": m.content]
        case .toolCall(let m):
            let content = m.calls.map { "\($0.name)(\($0.arguments))" }.joined(separator: "\n")
            return ["role": ChatMessageRole.assistant.rawValue, "content": content]
        case .toolResult(let m):
            return ["role": ChatMessageRole.tool.rawValue, "content": m.result]
        case .subagentLink:
            return ["role": ChatMessageRole.user.rawValue, "content": ""]
        case .attachment(let m):
            return ["role": ChatMessageRole.user.rawValue, "content": m.fileName ?? ""]
        }
    }
}
