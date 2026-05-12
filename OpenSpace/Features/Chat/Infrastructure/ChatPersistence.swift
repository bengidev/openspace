import ComposableArchitecture
import CoreData
import Foundation

enum PersistenceError: Error {
    case missingStoreDescription
    case localStoreLoadFailed(Error)
    case unknownMessageType(String)
    case missingPayload
}

struct ChatPersistenceClient {
    var fetchConversations: @Sendable () async throws -> [Conversation]
    var createConversation: @Sendable (Conversation) async throws -> Conversation
    var deleteConversation: @Sendable (UUID) async throws -> Void
    var searchConversations: @Sendable (String) async throws -> [Conversation]
    var saveMessage: @Sendable (Message, UUID) async throws -> Void
    var fetchMessages: @Sendable (UUID) async throws -> [Message]
    var deleteMessages: @Sendable (UUID) async throws -> Void
}

extension NSManagedObjectContext {
    func performAsync<T: Sendable>(_ operation: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    let result = try operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension ChatPersistenceClient: DependencyKey {
    static let liveValue = ChatPersistenceClient(
        fetchConversations: {
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            return try await context.performAsync {
                let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
                request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                let entities = try context.fetch(request)
                return entities.map { $0.toDomain() }
            }
        },
        createConversation: { conversation in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            try await context.performAsync {
                let entity = ConversationEntity(context: context)
                entity.conversationId = conversation.id
                entity.title = conversation.title
                entity.createdAt = conversation.createdAt
                entity.updatedAt = conversation.updatedAt
                entity.modelID = conversation.modelID
                entity.providerID = conversation.providerID
                try context.save()
            }
            return conversation
        },
        deleteConversation: { id in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            try await context.performAsync {
                let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
                request.predicate = NSPredicate(format: "conversationId == %@", id as CVarArg)
                let entities = try context.fetch(request)
                for entity in entities {
                    context.delete(entity)
                }

                let msgRequest = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
                msgRequest.predicate = NSPredicate(format: "conversationId == %@", id as CVarArg)
                let messages = try context.fetch(msgRequest)
                for message in messages {
                    context.delete(message)
                }

                try context.save()
            }
        },
        searchConversations: { query in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            return try await context.performAsync {
                let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
                request.predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@",
                    query
                )
                request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                let entities = try context.fetch(request)
                return entities.map { $0.toDomain() }
            }
        },
        saveMessage: { message, conversationId in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            try await context.performAsync {
                let entity = MessageEntity(context: context)
                entity.messageId = message.id
                entity.conversationId = conversationId
                entity.timestamp = message.timestamp
                entity.role = message.role.rawValue
                entity.messageType = message.messageTypeString
                entity.status = MessageStatus.complete.rawValue
                entity.payloadJSON = try message.encodePayload()
                try context.save()
            }
        },
        fetchMessages: { conversationId in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            return try await context.performAsync {
                let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
                request.predicate = NSPredicate(format: "conversationId == %@", conversationId as CVarArg)
                request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
                let entities = try context.fetch(request)
                return try entities.map { try $0.toDomain() }
            }
        },
        deleteMessages: { conversationId in
            let context = try await ChatCoreDataStack.shared.newBackgroundContext()
            try await context.performAsync {
                let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
                request.predicate = NSPredicate(format: "conversationId == %@", conversationId as CVarArg)
                let entities = try context.fetch(request)
                for entity in entities {
                    context.delete(entity)
                }
                try context.save()
            }
        }
    )

    static let testValue = ChatPersistenceClient(
        fetchConversations: { [] },
        createConversation: { $0 },
        deleteConversation: { _ in },
        searchConversations: { _ in [] },
        saveMessage: { _, _ in },
        fetchMessages: { _ in [] },
        deleteMessages: { _ in }
    )
}

extension DependencyValues {
    var chatPersistence: ChatPersistenceClient {
        get { self[ChatPersistenceClient.self] }
        set { self[ChatPersistenceClient.self] = newValue }
    }
}

extension ConversationEntity {
    func toDomain() -> Conversation {
        Conversation(
            id: conversationId,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            modelID: modelID,
            providerID: providerID
        )
    }
}

extension MessageEntity {
    func toDomain() throws -> Message {
        guard let type = MessageType(rawValue: messageType) else {
            throw PersistenceError.unknownMessageType(messageType)
        }
        guard let payloadJSON = payloadJSON else {
            throw PersistenceError.missingPayload
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        switch type {
        case .text:
            let payload = try decoder.decode(TextMessage.self, from: payloadJSON)
            return .text(payload)
        case .thinking:
            let payload = try decoder.decode(ThinkingMessage.self, from: payloadJSON)
            return .thinking(payload)
        case .toolCall:
            let payload = try decoder.decode(ToolCallMessage.self, from: payloadJSON)
            return .toolCall(payload)
        case .toolResult:
            let payload = try decoder.decode(ToolResultMessage.self, from: payloadJSON)
            return .toolResult(payload)
        case .subagentLink:
            let payload = try decoder.decode(SubagentLinkMessage.self, from: payloadJSON)
            return .subagentLink(payload)
        case .attachment:
            let payload = try decoder.decode(AttachmentMessage.self, from: payloadJSON)
            return .attachment(payload)
        case .system:
            let payload = try decoder.decode(SystemMessage.self, from: payloadJSON)
            return .system(payload)
        }
    }
}

private enum MessageType: String {
    case text
    case thinking
    case toolCall
    case toolResult
    case subagentLink
    case attachment
    case system
}

private extension Message {
    var messageTypeString: String {
        switch self {
        case .text: return "text"
        case .thinking: return "thinking"
        case .toolCall: return "toolCall"
        case .toolResult: return "toolResult"
        case .subagentLink: return "subagentLink"
        case .attachment: return "attachment"
        case .system: return "system"
        }
    }

    func encodePayload() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        switch self {
        case let .text(m): return try encoder.encode(m)
        case let .thinking(m): return try encoder.encode(m)
        case let .toolCall(m): return try encoder.encode(m)
        case let .toolResult(m): return try encoder.encode(m)
        case let .subagentLink(m): return try encoder.encode(m)
        case let .attachment(m): return try encoder.encode(m)
        case let .system(m): return try encoder.encode(m)
        }
    }
}
