import ComposableArchitecture
import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct ChatConversationListTests {
    @Test
    func loadConversationsOnAppear() async throws {
        let conversation = ChatConversation(title: "Test Chat")
        let store = TestStore(initialState: ChatConversationList.State()) {
            ChatConversationList()
        } withDependencies: {
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.fetchConversations = { [conversation] }
            $0[ChatPersistenceClient.self] = chatPersistence
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
        let newConversation = ChatConversation(title: "New Conversation")
        let store = TestStore(initialState: ChatConversationList.State()) {
            ChatConversationList()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 0)
            $0.uuid = .constant(UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.createConversation = { _ in newConversation }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.createConversationTapped)
        await store.receive(.conversationCreated(newConversation)) {
            $0.conversations = [newConversation]
            $0.selectedConversation = newConversation
        }
    }

    @Test
    func deleteConversation() async throws {
        let conversation = ChatConversation(title: "To Delete")
        let store = TestStore(initialState: ChatConversationList.State(conversations: [conversation])) {
            ChatConversationList()
        } withDependencies: {
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.deleteConversation = { _ in }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.deleteConversationTapped(conversation.id))
        await store.receive(.conversationDeleted(conversation.id)) {
            $0.conversations = []
        }
    }

    @Test
    func searchConversations() async throws {
        let result = ChatConversation(title: "Search Result")
        let clock = TestClock()
        let store = TestStore(initialState: ChatConversationList.State()) {
            ChatConversationList()
        } withDependencies: {
            $0.continuousClock = clock
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.searchConversations = { _ in [result] }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.searchQueryChanged("query")) {
            $0.searchQuery = "query"
            $0.isLoading = true
        }
        await clock.advance(by: .milliseconds(220))
        await store.receive(.searchResultsLoaded(query: "query", [result])) {
            $0.isLoading = false
            $0.conversations = [result]
        }
    }

    @Test
    func selectAndDeselectConversation() async throws {
        let conversation = ChatConversation(title: "Selected")
        let store = TestStore(initialState: ChatConversationList.State()) {
            ChatConversationList()
        }

        await store.send(.conversationSelected(conversation)) {
            $0.selectedConversation = conversation
        }

        await store.send(.deselectConversation) {
            $0.selectedConversation = nil
        }
    }
}
