import ComposableArchitecture
import SwiftUI

struct HomeContainerView: View {
    @Bindable var store: StoreOf<HomeContainer>

    var body: some View {
        HomeView(store: store)
    }
}

@Reducer
struct HomeContainer {
    @ObservableState
    struct State: Equatable {
        var spacerPet = SpacerPetContainer.State()
        var chat = ChatTab.State()
    }

    @CasePathable
    enum Action: Equatable {
        case spacerPet(SpacerPetContainer.Action)
        case chat(ChatTab.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.spacerPet, action: \.spacerPet) {
            SpacerPetContainer()
        }

        Scope(state: \.chat, action: \.chat) {
            ChatTab()
        }
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
