import ComposableArchitecture
import Foundation
import SwiftData

struct ChatPersistenceClient: Sendable {
    var fetchConversations: @Sendable () async throws -> [ChatConversation]
    var createConversation: @Sendable (ChatConversation) async throws -> ChatConversation
    var deleteConversation: @Sendable (UUID) async throws -> Void
    var searchConversations: @Sendable (String) async throws -> [ChatConversation]
    var saveMessage: @Sendable (ChatMessage, UUID) async throws -> Void
    var fetchMessages: @Sendable (UUID) async throws -> [ChatMessage]
    var deleteMessages: @Sendable (UUID) async throws -> Void
}

extension ChatPersistenceClient {
    static func live(modelContainer: ModelContainer) -> Self {
        let store = ChatPersistenceStore(modelContainer: modelContainer)
        return Self(
            fetchConversations: {
                try await store.fetchConversations()
            },
            createConversation: { conversation in
                try await store.createConversation(conversation)
            },
            deleteConversation: { id in
                try await store.deleteConversation(id)
            },
            searchConversations: { query in
                try await store.searchConversations(query)
            },
            saveMessage: { message, conversationID in
                try await store.saveMessage(message, conversationID: conversationID)
            },
            fetchMessages: { conversationID in
                try await store.fetchMessages(conversationID: conversationID)
            },
            deleteMessages: { conversationID in
                try await store.deleteMessages(conversationID: conversationID)
            }
        )
    }
}

extension ChatPersistenceClient: DependencyKey {
    static let liveValue = Self.live(modelContainer: OpenSpaceModelContainer.shared)

    static let testValue = Self(
        fetchConversations: { [] },
        createConversation: { $0 },
        deleteConversation: { _ in },
        searchConversations: { _ in [] },
        saveMessage: { _, _ in },
        fetchMessages: { _ in [] },
        deleteMessages: { _ in }
    )

    static let previewValue = Self(
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
