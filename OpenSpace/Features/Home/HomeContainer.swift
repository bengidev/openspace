import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeContainer {
    @ObservableState
    struct State: Equatable {
        var selectedTab: HomeTab = .chat
        var spacerPet = SpacerPetContainer.State()
        var chat = ChatTabState()
        var settings = SettingsTabState()
    }

    @CasePathable
    enum Action: Equatable {
        case tabSelected(HomeTab)
        case spacerPet(SpacerPetContainer.Action)
        case chat(ChatTabAction)
        case settings(SettingsTabAction)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.spacerPet, action: \.spacerPet) {
            SpacerPetContainer()
        }

        Scope(state: \.chat, action: \.chat) {
            ChatTab()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsTab()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .spacerPet, .chat, .settings:
                return .none
            }
        }
    }
}

struct HomeContainerView: View {
    @Bindable var store: StoreOf<HomeContainer>

    var body: some View {
        HomeView(store: store)
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
