import SwiftUI

struct ThemeToggleButton: View {
    var appTheme: Binding<AppTheme>
    var resolvedIsDark: Bool

    @State private var pulsePhase = false

    private var isSystemMode: Bool {
        appTheme.wrappedValue == .system
    }

    var body: some View {
        ZStack {
            // Track background with gradient and shadow
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.08, blue: 0.08),
                            Color(red: 0.03, green: 0.03, blue: 0.03),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 26)
                .shadow(
                    color: .black.opacity(0.32),
                    radius: 2,
                    x: 0,
                    y: 2
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(
                            isSystemMode
                                ? Color.white.opacity(0.12)
                                : Color.white.opacity(0.05),
                            lineWidth: isSystemMode ? 0.8 : 0.5
                        )
                )

            HStack {
                if resolvedIsDark {
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.42, blue: 0.11))
                    .frame(width: 10, height: 20)
                    .padding(.horizontal, 3)

                if !resolvedIsDark {
                    Spacer()
                }
            }
            .frame(width: 30, height: 26)
        }
        .frame(width: 30, height: 26)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                appTheme.wrappedValue = appTheme.wrappedValue.next
            }
        }
    }
}

#Preview("Light") {
    ThemeToggleButton(appTheme: .constant(.light), resolvedIsDark: false)
        .padding()
}

#Preview("Dark") {
    ThemeToggleButton(appTheme: .constant(.dark), resolvedIsDark: true)
        .padding()
        .preferredColorScheme(.dark)
}
