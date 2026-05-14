import Foundation
import SwiftData

@MainActor
final class ChatPersistenceStore {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchConversations() throws -> [ChatConversation] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<ChatConversationRecord>(
            sortBy: [SortDescriptor(\ChatConversationRecord.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(ChatPersistenceMapper.conversation(from:))
    }

    func createConversation(_ conversation: ChatConversation) throws -> ChatConversation {
        let context = ModelContext(modelContainer)
        if let existingRecord = try fetchConversationRecord(id: conversation.id, in: context) {
            ChatPersistenceMapper.update(existingRecord, from: conversation)
        } else {
            context.insert(ChatPersistenceMapper.makeConversationRecord(from: conversation))
        }
        try context.save()
        return conversation
    }

    func deleteConversation(_ id: UUID) throws {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<ChatConversationRecord>(
            predicate: #Predicate<ChatConversationRecord> { record in
                record.conversationID == id
            }
        )
        let records = try context.fetch(descriptor)
        records.forEach(context.delete)
        try context.save()
    }

    func searchConversations(_ query: String) throws -> [ChatConversation] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            return try fetchConversations()
        }

        return try fetchConversations().filter {
            $0.title.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    func saveMessage(_ message: ChatMessage, conversationID: UUID) throws {
        let context = ModelContext(modelContainer)
        guard let conversationRecord = try fetchConversationRecord(id: conversationID, in: context) else {
            throw ChatPersistenceError.missingConversation(conversationID)
        }

        if let existingRecord = try fetchMessageRecord(id: message.id, in: context) {
            try ChatPersistenceMapper.update(
                existingRecord,
                from: message,
                conversationID: conversationID,
                conversation: conversationRecord
            )
        } else {
            context.insert(
                try ChatPersistenceMapper.makeMessageRecord(
                    from: message,
                    conversationID: conversationID,
                    conversation: conversationRecord
                )
            )
        }

        conversationRecord.updatedAt = max(conversationRecord.updatedAt, message.timestamp)
        try context.save()
    }

    func fetchMessages(conversationID: UUID) throws -> [ChatMessage] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<ChatMessageRecord>(
            predicate: #Predicate<ChatMessageRecord> { record in
                record.conversationID == conversationID
            },
            sortBy: [SortDescriptor(\ChatMessageRecord.timestamp)]
        )
        return try context.fetch(descriptor).map(ChatPersistenceMapper.message(from:))
    }

    func deleteMessages(conversationID: UUID) throws {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<ChatMessageRecord>(
            predicate: #Predicate<ChatMessageRecord> { record in
                record.conversationID == conversationID
            }
        )
        let records = try context.fetch(descriptor)
        records.forEach(context.delete)
        try context.save()
    }

    private func fetchConversationRecord(id: UUID, in context: ModelContext) throws -> ChatConversationRecord? {
        let descriptor = FetchDescriptor<ChatConversationRecord>(
            predicate: #Predicate<ChatConversationRecord> { record in
                record.conversationID == id
            }
        )
        return try context.fetch(descriptor).first
    }

    private func fetchMessageRecord(id: UUID, in context: ModelContext) throws -> ChatMessageRecord? {
        let descriptor = FetchDescriptor<ChatMessageRecord>(
            predicate: #Predicate<ChatMessageRecord> { record in
                record.messageID == id
            }
        )
        return try context.fetch(descriptor).first
    }
}
