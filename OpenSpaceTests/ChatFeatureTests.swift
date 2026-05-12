import ComposableArchitecture
import CoreData
import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct ConversationListTests {
    @Test
    func loadConversationsOnAppear() async throws {
        let conversation = Conversation(title: "Test Chat")
        let store = TestStore(initialState: ConversationList.State()) {
            ConversationList()
        } withDependencies: {
            $0.chatPersistence.fetchConversations = { [conversation] }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(.conversationsLoaded([conversation])) {
            $0.isLoading = false
            $0.conversations = [conversation]
        }
    }

    @Test
    func createConversation() async throws {
        let newConversation = Conversation(title: "New Conversation")
        let store = TestStore(initialState: ConversationList.State()) {
            ConversationList()
        } withDependencies: {
            $0.chatPersistence.createConversation = { _ in newConversation }
        }

        await store.send(.createConversationTapped)
        await store.receive(.conversationCreated(newConversation)) {
            $0.conversations = [newConversation]
            $0.selectedConversation = newConversation
        }
    }

    @Test
    func deleteConversation() async throws {
        let conversation = Conversation(title: "To Delete")
        let store = TestStore(initialState: ConversationList.State(conversations: [conversation])) {
            ConversationList()
        } withDependencies: {
            $0.chatPersistence.deleteConversation = { _ in }
        }

        await store.send(.deleteConversationTapped(conversation.id))
        await store.receive(.conversationDeleted(conversation.id)) {
            $0.conversations = []
        }
    }

    @Test
    func searchConversations() async throws {
        let result = Conversation(title: "Search Result")
        let store = TestStore(initialState: ConversationList.State()) {
            ConversationList()
        } withDependencies: {
            $0.chatPersistence.searchConversations = { _ in [result] }
        }

        await store.send(.searchQueryChanged("query")) {
            $0.searchQuery = "query"
            $0.isLoading = true
        }
        await store.receive(.searchResultsLoaded([result])) {
            $0.isLoading = false
            $0.conversations = [result]
        }
    }

    @Test
    func selectAndDeselectConversation() async throws {
        let conversation = Conversation(title: "Selected")
        let store = TestStore(initialState: ConversationList.State()) {
            ConversationList()
        }

        await store.send(.conversationSelected(conversation)) {
            $0.selectedConversation = conversation
        }

        await store.send(.deselectConversation) {
            $0.selectedConversation = nil
        }
    }
}

@MainActor
struct CoreDataSerializationTests {
    private func makeInMemoryContext() throws -> NSManagedObjectContext {
        let model = ChatCoreDataStack.createTestModel()
        let container = NSPersistentContainer(name: "TestModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let error = loadError { throw error }

        return container.viewContext
    }

    @Test
    func conversationRoundTrip() async throws {
        let context = try makeInMemoryContext()
        let entity = ConversationEntity(context: context)
        entity.conversationId = UUID()
        entity.title = "Round Trip Test"
        entity.createdAt = Date()
        entity.updatedAt = Date()
        entity.modelID = "gpt-4"
        entity.providerID = "openai"

        let domain = entity.toDomain()

        #expect(domain.title == "Round Trip Test")
        #expect(domain.modelID == "gpt-4")
        #expect(domain.providerID == "openai")
    }

    @Test
    func messageTextRoundTrip() async throws {
        let context = try makeInMemoryContext()
        let entity = MessageEntity(context: context)
        entity.messageId = UUID()
        entity.conversationId = UUID()
        entity.timestamp = Date()
        entity.role = "user"
        entity.messageType = "text"
        entity.status = "complete"

        let payload = TextMessage(role: .user, content: "Hello")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        entity.payloadJSON = try encoder.encode(payload)

        let domain = try entity.toDomain()

        guard case let .text(textMsg) = domain else {
            Issue.record("Expected text message")
            return
        }
        #expect(textMsg.content == "Hello")
        #expect(textMsg.role == .user)
    }
}
