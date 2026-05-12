import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<HomeContainer>

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            ChatTabView(
                store: store.scope(state: \.chat, action: \.chat)
            )
        }
    }
}

struct SettingsTabView: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack {
                Text("Settings")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(palette.textPrimary)
                    .tracking(-1.2)

                Spacer()
            }
            .padding(.top, 60)
        }
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeContainer.State()) {
            HomeContainer()
        }
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
