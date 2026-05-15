import ComposableArchitecture
import Testing

@testable import OpenSpace

@MainActor
struct HomeContainerTests {
    @Test
    func selectingConversationFromSidebarLoadsMessagesIntoMainChat() async {
        let conversation = ChatConversation(
            title: "Existing GPT-5.5 Thread",
            modelID: ComposerModelOption.gpt55.rawValue,
            providerID: "openai"
        )
        let message = ChatMessage.text(
            ChatTextMessage(role: .assistant, content: "Loaded from persistence")
        )

        let store = TestStore(initialState: HomeContainer.State()) {
            HomeContainer()
        } withDependencies: {
            var chatPersistence = ChatPersistenceClient.testValue
            chatPersistence.fetchMessages = { conversationID in
                #expect(conversationID == conversation.id)
                return [message]
            }
            $0[ChatPersistenceClient.self] = chatPersistence
        }

        await store.send(.sideStory(.conversationList(.conversationSelected(conversation)))) {
            $0.sideStory.conversationList.selectedConversation = conversation
            $0.mainChat.selectedConversation = conversation
            $0.mainChat.selectedModel = .gpt55
        }
        await store.receive(.mainChat(.messagesLoaded([message]))) {
            $0.mainChat.messages = [message]
            $0.mainChat.threadEngine.messages = [message]
        }
    }
}
