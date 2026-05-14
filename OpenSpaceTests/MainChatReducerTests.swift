import ComposableArchitecture
import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct MainChatReducerTests {
    @Test
    func composerSelectionsUpdateState() async {
        let store = TestStore(initialState: MainChat.State()) {
            MainChat()
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
        let conversation = ChatConversation(
            title: "Existing GPT-5.5 Thread",
            modelID: ComposerModelOption.gpt55.rawValue,
            providerID: "openai"
        )
        let message = ChatMessage.text(
            ChatTextMessage(role: .assistant, content: "Hello")
        )
        let store = TestStore(initialState: MainChat.State()) {
            MainChat()
        } withDependencies: {
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.fetchMessages = { _ in [message] }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.conversationSelected(conversation)) {
            $0.selectedConversation = conversation
            $0.messages = []
            $0.selectedModel = .gpt55
        }

        await store.receive(.messagesLoaded([message])) {
            $0.messages = [message]
        }
    }

    @Test
    func whitespaceOnlyDraftDoesNotSend() async {
        let store = TestStore(initialState: MainChat.State()) {
            MainChat()
        }

        await store.send(.draftMessageChanged("   \n  ")) {
            $0.draftMessage = "   \n  "
        }

        await store.send(.sendMessageTapped) {
            $0.draftMessage = ""
        }
    }

    @Test
    func firstMessageCreatesConversationAndPersistsMessage() async {
        let timestamp = Date(timeIntervalSince1970: 1_234_567)
        let conversationID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let messageID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let expectedConversation = ChatConversation(
            id: conversationID,
            title: "Hello from OpenSpace",
            createdAt: timestamp,
            updatedAt: timestamp,
            modelID: ComposerModelOption.gpt54.rawValue,
            providerID: "openai"
        )
        let expectedMessage = ChatMessage.text(
            ChatTextMessage(
                id: messageID,
                role: .user,
                content: "Hello from OpenSpace",
                timestamp: timestamp
            )
        )

        let store = TestStore(initialState: MainChat.State(draftMessage: "Hello from OpenSpace")) {
            MainChat()
        } withDependencies: {
            $0.date.now = timestamp
            $0.uuid = .incrementing
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.createConversation = { conversation in
                #expect(conversation == expectedConversation)
                return conversation
            }
            chatPersistence.saveMessage = { message, conversationID in
                #expect(message == expectedMessage)
                #expect(conversationID == expectedConversation.id)
            }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.sendMessageTapped) {
            $0.draftMessage = ""
            $0.isSending = true
        }
        await store.receive(.conversationCreated(expectedConversation)) {
            $0.selectedConversation = expectedConversation
        }
        await store.receive(.messageSent(expectedMessage)) {
            $0.isSending = false
            $0.messages = [expectedMessage]
            $0.selectedConversation = expectedConversation
        }
    }
}
