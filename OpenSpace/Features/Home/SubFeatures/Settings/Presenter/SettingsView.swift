import SwiftUI

struct SettingsView: View {
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
