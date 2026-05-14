import Foundation
import SwiftData

@Model
final class ChatConversationRecord {
    @Attribute(.unique) var conversationID: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var modelID: String?
    var providerID: String?
    @Relationship(deleteRule: .cascade, inverse: \ChatMessageRecord.conversation)
    var messages: [ChatMessageRecord]

    init(
        conversationID: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        modelID: String? = nil,
        providerID: String? = nil,
        messages: [ChatMessageRecord] = []
    ) {
        self.conversationID = conversationID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.modelID = modelID
        self.providerID = providerID
        self.messages = messages
    }
}
