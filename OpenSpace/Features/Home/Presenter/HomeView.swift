import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<HomeContainer>

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Hi! How can I help you?")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text("Chats are end-to-end encrypted.")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.top, 10)

                Text("Your data is safe.")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(28)

            SpacerPetContainerView(
                store: store.scope(state: \.spacerPet, action: \.spacerPet)
            )
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            store.send(.spacerPet(.feature(.onAppear)))
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
