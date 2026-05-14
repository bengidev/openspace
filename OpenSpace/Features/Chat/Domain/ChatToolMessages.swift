import Foundation

struct ChatToolCallMessage: ChatMessagePayload, Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: ChatMessageRole
    var calls: [ChatToolCall]
    var status: ChatToolCallStatus
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        calls: [ChatToolCall] = [],
        status: ChatToolCallStatus = .pending,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.calls = calls
        self.status = status
        self.timestamp = timestamp
    }
}

struct ChatToolResultMessage: ChatMessagePayload, Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: ChatMessageRole
    var callId: String
    var result: String
    var approved: Bool
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: ChatMessageRole,
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

struct ChatToolCall: Equatable, Identifiable, Sendable, Codable {
    let id: String
    var name: String
    var arguments: String

    nonisolated init(id: String, name: String, arguments: String) {
        self.id = id
        self.name = name
        self.arguments = arguments
    }
}

enum ChatToolCallStatus: String, Equatable, Sendable, Codable {
    case pending
    case approved
    case executed
}
