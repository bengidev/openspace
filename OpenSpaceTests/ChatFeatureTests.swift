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
        let clock = TestClock()
        let store = TestStore(initialState: ConversationList.State()) {
            ConversationList()
        } withDependencies: {
            $0.continuousClock = clock
            $0.chatPersistence.searchConversations = { _ in [result] }
        }

        await store.send(.searchQueryChanged("query")) {
            $0.searchQuery = "query"
        }
        await clock.advance(by: .milliseconds(220))
        await store.receive(.searchResultsLoaded(query: "query", [result])) {
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
struct ChatTabComposerTests {
    @Test
    func composerSelectionsUpdateState() async {
        let store = TestStore(initialState: ChatTab.State()) {
            ChatTab()
        }

        await store.send(.composerModelSelected(.gpt55)) {
            $0.selectedModel = .gpt55
        }

        await store.send(.reasoningLevelSelected(.medium)) {
            $0.reasoningLevel = .medium
        }

        await store.send(.executionScopeSelected(.hybrid)) {
            $0.executionScope = .hybrid
        }

        await store.send(.toolPolicySelected(.auto)) {
            $0.toolPolicy = .auto
        }

        await store.send(.branchSelected(.lab)) {
            $0.selectedBranch = .lab
        }
    }

    @Test
    func selectedConversationRestoresComposerModel() async {
        let conversation = Conversation(
            title: "Existing GPT-5.5 Thread",
            modelID: ComposerModelOption.gpt55.rawValue,
            providerID: "openai"
        )
        let store = TestStore(initialState: ChatTab.State()) {
            ChatTab()
        } withDependencies: {
            $0.chatPersistence.fetchMessages = { _ in [] }
        }

        await store.send(.conversationList(.conversationSelected(conversation))) {
            $0.conversationList.selectedConversation = conversation
            $0.messages = []
            $0.selectedModel = .gpt55
        }

        await store.receive(.messagesLoaded([]))
    }

    @Test
    func whitespaceOnlyDraftDoesNotSend() async {
        let store = TestStore(initialState: ChatTab.State()) {
            ChatTab()
        }

        await store.send(.draftMessageChanged("   \n  ")) {
            $0.draftMessage = "   \n  "
        }

        await store.send(.sendMessageTapped) {
            $0.draftMessage = ""
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
