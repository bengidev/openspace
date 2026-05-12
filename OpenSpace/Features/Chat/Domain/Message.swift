import Foundation

enum Message: Equatable, Identifiable, Sendable {
    case text(TextMessage)
    case thinking(ThinkingMessage)
    case toolCall(ToolCallMessage)
    case toolResult(ToolResultMessage)
    case subagentLink(SubagentLinkMessage)
    case attachment(AttachmentMessage)
    case system(SystemMessage)

    var id: UUID {
        switch self {
        case let .text(m): return m.id
        case let .thinking(m): return m.id
        case let .toolCall(m): return m.id
        case let .toolResult(m): return m.id
        case let .subagentLink(m): return m.id
        case let .attachment(m): return m.id
        case let .system(m): return m.id
        }
    }

    var role: MessageRole {
        switch self {
        case let .text(m): return m.role
        case let .thinking(m): return m.role
        case let .toolCall(m): return m.role
        case let .toolResult(m): return m.role
        case let .subagentLink(m): return m.role
        case let .attachment(m): return m.role
        case let .system(m): return m.role
        }
    }

    var timestamp: Date {
        switch self {
        case let .text(m): return m.timestamp
        case let .thinking(m): return m.timestamp
        case let .toolCall(m): return m.timestamp
        case let .toolResult(m): return m.timestamp
        case let .subagentLink(m): return m.timestamp
        case let .attachment(m): return m.timestamp
        case let .system(m): return m.timestamp
        }
    }
}

enum MessageRole: String, Equatable, Sendable, Codable {
    case user
    case assistant
    case system
    case tool
}

enum MessageStatus: String, Equatable, Sendable, Codable {
    case streaming
    case complete
    case failed
}

struct TextMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var content: String
    var isComplete: Bool
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        isComplete: Bool = true,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.isComplete = isComplete
        self.timestamp = timestamp
    }
}

struct ThinkingMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var content: String
    var isComplete: Bool
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        isComplete: Bool = true,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.isComplete = isComplete
        self.timestamp = timestamp
    }
}

struct ToolCallMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var calls: [ToolCall]
    var status: ToolCallStatus
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        calls: [ToolCall] = [],
        status: ToolCallStatus = .pending,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.calls = calls
        self.status = status
        self.timestamp = timestamp
    }
}

struct ToolResultMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var callId: String
    var result: String
    var approved: Bool
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        callId: String,
        result: String,
        approved: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.callId = callId
        self.result = result
        self.approved = approved
        self.timestamp = timestamp
    }
}

struct SubagentLinkMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var link: ThreadLink
    var status: SubagentStatus
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        link: ThreadLink,
        status: SubagentStatus = .running,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.link = link
        self.status = status
        self.timestamp = timestamp
    }
}

struct AttachmentMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var type: AttachmentType
    var url: URL?
    var fileName: String?
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole,
        type: AttachmentType,
        url: URL? = nil,
        fileName: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.type = type
        self.url = url
        self.fileName = fileName
        self.timestamp = timestamp
    }
}

struct SystemMessage: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: MessageRole = .system,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct ToolCall: Equatable, Identifiable, Sendable, Codable {
    let id: String
    var name: String
    var arguments: String

    nonisolated init(id: String, name: String, arguments: String) {
        self.id = id
        self.name = name
        self.arguments = arguments
    }
}

enum ToolCallStatus: String, Equatable, Sendable, Codable {
    case pending
    case approved
    case executed
}

struct ThreadLink: Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    var childConversationId: UUID
    var agentName: String
    var role: String

    nonisolated init(
        id: UUID = UUID(),
        childConversationId: UUID,
        agentName: String,
        role: String
    ) {
        self.id = id
        self.childConversationId = childConversationId
        self.agentName = agentName
        self.role = role
    }
}

enum SubagentStatus: String, Equatable, Sendable, Codable {
    case running
    case done
    case failed
}

enum AttachmentType: String, Equatable, Sendable, Codable {
    case image
    case audio
    case file
}
