import ComposableArchitecture
import SwiftUI

struct HomeContainerView: View {
    @Bindable var store: StoreOf<HomeContainer>

    var body: some View {
        HomeRootView(store: store)
    }
}

@Reducer
struct HomeContainer {
    @Dependency(ChatPersistenceClient.self) private var chatPersistence

    @ObservableState
    struct State: Equatable {
        var spacerPet = SpacerPetContainer.State()
        var mainChat = MainChat.State()
        var sideStory = SideStory.State()
        var settings = Settings.State()
    }

    @CasePathable
    enum Action: Equatable {
        case spacerPet(SpacerPetContainer.Action)
        case mainChat(MainChat.Action)
        case sideStory(SideStory.Action)
        case settings(Settings.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.spacerPet, action: \.spacerPet) {
            SpacerPetContainer()
        }

        Scope(state: \.mainChat, action: \.mainChat) {
            MainChat()
        }

        Scope(state: \.sideStory, action: \.sideStory) {
            SideStory()
        }

        Scope(state: \.settings, action: \.settings) {
            Settings()
        }

        Reduce { state, action in
            switch action {
            case .mainChat(.sidebarToggleTapped):
                return .send(.sideStory(.sidebarToggleTapped))

            case .mainChat(.sidebarDismissed):
                return .send(.sideStory(.sidebarDismissed))

            case .mainChat(.newConversationTapped):
                state.mainChat.selectedConversation = nil
                state.mainChat.messages = []
                state.mainChat.threadEngine.messages = []
                state.mainChat.threadEngine.streamingStatus = .idle
                state.mainChat.threadEngine.currentPartialText = ""
                return .send(.sideStory(.newConversationTapped))

            case .mainChat(.conversationCreated(let conversation)):
                return .send(.sideStory(.conversationCreated(conversation)))

            case .mainChat(.conversationSelected(let conversation)):
                state.sideStory.conversationList.selectedConversation = conversation
                state.mainChat.messages = []
                state.mainChat.threadEngine.messages = []
                state.mainChat.threadEngine.streamingStatus = .idle
                state.mainChat.threadEngine.currentPartialText = ""
                return .none

            case .mainChat(.messageSent(let message)):
                guard let conversation = state.mainChat.selectedConversation else {
                    return .none
                }

                let updatedConversation = Self.updatedConversation(conversation, with: message.timestamp)
                state.mainChat.selectedConversation = updatedConversation
                state.sideStory.conversationList.selectedConversation = updatedConversation
                state.sideStory.conversationList.conversations = Self.upsertConversation(
                    updatedConversation,
                    in: state.sideStory.conversationList.conversations
                )
                return .none

            case .sideStory(.settingsTapped):
                state.settings.isPresented = true
                return .none

            case .sideStory(.conversationList(.conversationSelected(let conversation))):
                state.mainChat.selectedConversation = conversation
                state.mainChat.messages = []
                state.mainChat.threadEngine.messages = []
                state.mainChat.threadEngine.streamingStatus = .idle
                state.mainChat.threadEngine.currentPartialText = ""
                if let model = ComposerModelOption.resolve(modelID: conversation.modelID) {
                    state.mainChat.selectedModel = model
                }
                return .run { send in
                    let messages = try await chatPersistence.fetchMessages(conversation.id)
                    await send(.mainChat(.messagesLoaded(messages)))
                }

            case .sideStory(.newConversationTapped):
                state.mainChat.selectedConversation = nil
                state.mainChat.messages = []
                state.mainChat.threadEngine.messages = []
                state.mainChat.threadEngine.streamingStatus = .idle
                state.mainChat.threadEngine.currentPartialText = ""
                return .none

            case .settings(.dismiss):
                state.settings.isPresented = false
                return .none

            default:
                return .none
            }
        }
    }

    private static func updatedConversation(_ conversation: ChatConversation, with timestamp: Date) -> ChatConversation {
        var updatedConversation = conversation
        updatedConversation.updatedAt = timestamp
        return updatedConversation
    }

    private static func upsertConversation(
        _ conversation: ChatConversation,
        in conversations: [ChatConversation]
    ) -> [ChatConversation] {
        var nextConversations = conversations
        nextConversations.removeAll { $0.id == conversation.id }
        nextConversations.insert(conversation, at: 0)
        return nextConversations
    }
}

#Preview {
    HomeContainerView(
        store: Store(initialState: HomeContainer.State()) {
            HomeContainer()
        }
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
