import ComposableArchitecture
import SwiftUI

struct HomeRootView: View {
    let store: StoreOf<HomeContainer>

    @Environment(\.palette) private var palette

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                palette.background
                    .ignoresSafeArea()

                MainChatView(
                    store: store.scope(state: \.mainChat, action: \.mainChat),
                    isSidebarVisible: store.sideStory.isSidebarVisible
                )

                SideStoryOverlay(
                    store: store.scope(state: \.sideStory, action: \.sideStory),
                    modelTitle: store.mainChat.selectedModel.title,
                    branchTitle: store.mainChat.selectedBranch.title,
                    safeAreaInsets: proxy.safeAreaInsets
                )
                .ignoresSafeArea(.container, edges: .vertical)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { store.settings.isPresented },
                set: { isPresented in
                    if !isPresented {
                        store.send(.settings(.dismiss))
                    }
                }
            )
        ) {
            SettingsView()
        }
    }
}
