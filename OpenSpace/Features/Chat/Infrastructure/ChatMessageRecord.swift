import Foundation
import SwiftData

@Model
final class ChatMessageRecord {
    @Attribute(.unique) var messageID: UUID
    var conversationID: UUID
    var timestamp: Date
    var role: String
    var messageKind: String
    var status: String
    @Attribute(.externalStorage) var payloadData: Data
    var conversation: ChatConversationRecord?

    init(
        messageID: UUID = UUID(),
        conversationID: UUID,
        timestamp: Date,
        role: String,
        messageKind: String,
        status: String,
        payloadData: Data,
        conversation: ChatConversationRecord? = nil
    ) {
        self.messageID = messageID
        self.conversationID = conversationID
        self.timestamp = timestamp
        self.role = role
        self.messageKind = messageKind
        self.status = status
        self.payloadData = payloadData
        self.conversation = conversation
    }
}
