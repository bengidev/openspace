import Foundation

enum ChatPersistenceMapper {
    static func makeConversationRecord(from conversation: ChatConversation) -> ChatConversationRecord {
        ChatConversationRecord(
            conversationID: conversation.id,
            title: conversation.title,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            modelID: conversation.modelID,
            providerID: conversation.providerID
        )
    }

    static func update(_ record: ChatConversationRecord, from conversation: ChatConversation) {
        record.title = conversation.title
        record.createdAt = conversation.createdAt
        record.updatedAt = conversation.updatedAt
        record.modelID = conversation.modelID
        record.providerID = conversation.providerID
    }

    static func conversation(from record: ChatConversationRecord) -> ChatConversation {
        ChatConversation(
            id: record.conversationID,
            title: record.title,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            modelID: record.modelID,
            providerID: record.providerID
        )
    }

    static func makeMessageRecord(
        from message: ChatMessage,
        conversationID: UUID,
        conversation: ChatConversationRecord
    ) throws -> ChatMessageRecord {
        let encoded = try ChatMessagePayloadCoder.encode(message)
        return ChatMessageRecord(
            messageID: message.id,
            conversationID: conversationID,
            timestamp: message.timestamp,
            role: message.role.rawValue,
            messageKind: encoded.kind.rawValue,
            status: encoded.status.rawValue,
            payloadData: encoded.payloadData,
            conversation: conversation
        )
    }

    static func update(
        _ record: ChatMessageRecord,
        from message: ChatMessage,
        conversationID: UUID,
        conversation: ChatConversationRecord
    ) throws {
        let encoded = try ChatMessagePayloadCoder.encode(message)
        record.conversationID = conversationID
        record.timestamp = message.timestamp
        record.role = message.role.rawValue
        record.messageKind = encoded.kind.rawValue
        record.status = encoded.status.rawValue
        record.payloadData = encoded.payloadData
        record.conversation = conversation
    }

    static func message(from record: ChatMessageRecord) throws -> ChatMessage {
        guard let kind = ChatMessageKind(rawValue: record.messageKind) else {
            throw ChatPersistenceError.unknownMessageKind(record.messageKind)
        }

        do {
            return try ChatMessagePayloadCoder.decode(kind: kind, payloadData: record.payloadData)
        } catch {
            throw ChatPersistenceError.invalidPayload(record.messageID.uuidString)
        }
    }
}
