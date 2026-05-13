import ComposableArchitecture
import SwiftUI

struct MainChatWelcomeView: View {
    let store: StoreOf<MainChat>

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 72)

            HomeAsciiParticleOrbView()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .padding(.bottom, 28)

            Text("Hi! How can I help you?")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text("Chats are end-to-end encrypted.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(palette.textSecondary)
                .padding(.top, 12)

            Text("Your data is safe.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(palette.textSecondary)
                .padding(.top, 4)

            Spacer()
        }
        .padding(.horizontal, 28)
    }
}
