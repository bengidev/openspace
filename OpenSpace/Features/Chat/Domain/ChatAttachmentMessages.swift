import Foundation

struct ChatSubagentLinkMessage: ChatMessagePayload, Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: ChatMessageRole
    var link: ChatThreadLink
    var status: ChatSubagentStatus
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        link: ChatThreadLink,
        status: ChatSubagentStatus = .running,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.link = link
        self.status = status
        self.timestamp = timestamp
    }
}

struct ChatAttachmentMessage: ChatMessagePayload, Equatable, Identifiable, Sendable, Codable {
    let id: UUID
    let role: ChatMessageRole
    var type: ChatAttachmentType
    var url: URL?
    var fileName: String?
    let timestamp: Date

    nonisolated init(
        id: UUID = UUID(),
        role: ChatMessageRole,
        type: ChatAttachmentType,
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

struct ChatThreadLink: Equatable, Identifiable, Sendable, Codable {
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

enum ChatSubagentStatus: String, Equatable, Sendable, Codable {
    case running
    case done
    case failed
}

enum ChatAttachmentType: String, Equatable, Sendable, Codable {
    case image
    case audio
    case file
}
