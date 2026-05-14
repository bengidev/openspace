import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct ChatPersistenceStoreTests {
    @Test
    func conversationRoundTrip() async throws {
        let modelContainer = try OpenSpaceModelContainer.makeInMemory()
        let store = ChatPersistenceStore(modelContainer: modelContainer)
        let conversation = ChatConversation(
            title: "Round Trip",
            modelID: "gpt-5.4",
            providerID: "openai"
        )

        let savedConversation = try await store.createConversation(conversation)
        let fetchedConversations = try await store.fetchConversations()

        #expect(savedConversation == conversation)
        #expect(fetchedConversations == [conversation])
    }

    @Test
    func messageRoundTrip() async throws {
        let modelContainer = try OpenSpaceModelContainer.makeInMemory()
        let store = ChatPersistenceStore(modelContainer: modelContainer)
        let conversation = ChatConversation(title: "Thread")
        let message = ChatMessage.text(
            ChatTextMessage(role: .user, content: "Hello")
        )

        _ = try await store.createConversation(conversation)
        try await store.saveMessage(message, conversationID: conversation.id)

        let fetchedMessages = try await store.fetchMessages(conversationID: conversation.id)

        #expect(fetchedMessages == [message])
    }

    @Test
    func deleteConversationCascadesMessages() async throws {
        let modelContainer = try OpenSpaceModelContainer.makeInMemory()
        let store = ChatPersistenceStore(modelContainer: modelContainer)
        let conversation = ChatConversation(title: "Cascade")
        let message = ChatMessage.text(
            ChatTextMessage(role: .user, content: "Delete me")
        )

        _ = try await store.createConversation(conversation)
        try await store.saveMessage(message, conversationID: conversation.id)
        try await store.deleteConversation(conversation.id)

        let fetchedConversations = try await store.fetchConversations()
        let fetchedMessages = try await store.fetchMessages(conversationID: conversation.id)

        #expect(fetchedConversations.isEmpty)
        #expect(fetchedMessages.isEmpty)
    }

    @Test
    func searchConversationsFiltersTitles() async throws {
        let modelContainer = try OpenSpaceModelContainer.makeInMemory()
        let store = ChatPersistenceStore(modelContainer: modelContainer)
        let swiftConversation = ChatConversation(title: "SwiftData Migration")
        let tcaConversation = ChatConversation(title: "TCA Dependency Graph")

        _ = try await store.createConversation(swiftConversation)
        _ = try await store.createConversation(tcaConversation)

        let results = try await store.searchConversations("swift")

        #expect(results == [swiftConversation])
    }
}
