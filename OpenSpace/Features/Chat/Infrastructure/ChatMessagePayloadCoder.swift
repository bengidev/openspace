import Foundation

enum ChatPersistenceError: Error, Equatable {
    case missingConversation(UUID)
    case unknownMessageKind(String)
    case invalidPayload(String)
}

enum ChatMessageKind: String, Sendable, Codable {
    case text
    case thinking
    case toolCall
    case toolResult
    case subagentLink
    case attachment
    case system
}

enum ChatMessagePayloadCoder {
    private static let encoderDateStrategy: JSONEncoder.DateEncodingStrategy = .custom { date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(date.timeIntervalSince1970)
    }

    private static let decoderDateStrategy: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let interval = try container.decode(TimeInterval.self)
        return Date(timeIntervalSince1970: interval)
    }

    static func encode(_ message: ChatMessage) throws -> (kind: ChatMessageKind, status: ChatMessageStatus, payloadData: Data) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = encoderDateStrategy

        switch message {
        case let .text(payload):
            return (.text, payload.isComplete ? .complete : .streaming, try encoder.encode(payload))
        case let .thinking(payload):
            return (.thinking, payload.isComplete ? .complete : .streaming, try encoder.encode(payload))
        case let .toolCall(payload):
            return (.toolCall, .complete, try encoder.encode(payload))
        case let .toolResult(payload):
            return (.toolResult, .complete, try encoder.encode(payload))
        case let .subagentLink(payload):
            return (.subagentLink, .complete, try encoder.encode(payload))
        case let .attachment(payload):
            return (.attachment, .complete, try encoder.encode(payload))
        case let .system(payload):
            return (.system, .complete, try encoder.encode(payload))
        }
    }

    static func decode(kind: ChatMessageKind, payloadData: Data) throws -> ChatMessage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = decoderDateStrategy

        switch kind {
        case .text:
            return .text(try decoder.decode(ChatTextMessage.self, from: payloadData))
        case .thinking:
            return .thinking(try decoder.decode(ChatThinkingMessage.self, from: payloadData))
        case .toolCall:
            return .toolCall(try decoder.decode(ChatToolCallMessage.self, from: payloadData))
        case .toolResult:
            return .toolResult(try decoder.decode(ChatToolResultMessage.self, from: payloadData))
        case .subagentLink:
            return .subagentLink(try decoder.decode(ChatSubagentLinkMessage.self, from: payloadData))
        case .attachment:
            return .attachment(try decoder.decode(ChatAttachmentMessage.self, from: payloadData))
        case .system:
            return .system(try decoder.decode(ChatSystemMessage.self, from: payloadData))
        }
    }
}
