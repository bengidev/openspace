import Foundation

// MARK: - WorkspaceThread

nonisolated struct WorkspaceThread: Identifiable, Equatable, Codable, Sendable {
    // MARK: Lifecycle

    init(
        id: UUID = UUID(),
        title: String,
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: WorkspaceModel = .chatGPT4o
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
    }

    // MARK: Internal

    static let mock = WorkspaceThread(
        id: UUID(),
        title: "Project Planning",
        messages: [
            Message(role: .user, content: "Help me plan my iOS app architecture"),
            Message(role: .assistant, content: "I'd recommend starting with a clear separation of concerns..."),
        ],
        model: .chatGPT4o
    )

    let id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    var model: WorkspaceModel
}

// MARK: - MessageRole

nonisolated enum MessageRole: String, Codable, Equatable, Sendable {
    case user
    case assistant
    case system
}

// MARK: - Message

nonisolated struct Message: Identifiable, Equatable, Codable, Sendable {
    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }

    let id: UUID
    let role: MessageRole
    var content: String
    let createdAt: Date
}
