import SwiftUI

struct ThemeToggleButton: View {
    var appTheme: Binding<AppTheme>
    var resolvedIsDark: Bool
    let palette: OpenSpaceOnboardingPalette

    @State private var tapped = false

    private var isSystemMode: Bool {
        appTheme.wrappedValue == .system
    }

    var body: some View {
        ZStack {
            // Track
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.surface.opacity(0.5))
                .frame(width: 30, height: 26)
                .shadow(
                    color: palette.textPrimary.opacity(0.1),
                    radius: 2,
                    x: 0,
                    y: 2
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(
                            isSystemMode ? palette.strongBorder : palette.border,
                            lineWidth: isSystemMode ? 0.8 : 0.5
                        )
                )

            // Sliding thumb
            HStack {
                if resolvedIsDark, !isSystemMode {
                    Spacer()
                }

                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(palette.accent)
                    .frame(width: 10, height: 20)
                    .shadow(
                        color: palette.accent.opacity(isSystemMode ? 0.30 : 0.50),
                        radius: isSystemMode ? 2 : 4,
                        x: 0,
                        y: 2
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                            .stroke(
                                isSystemMode
                                    ? palette.textPrimary.opacity(0.08)
                                    : palette.textPrimary.opacity(0.18),
                                lineWidth: 0.5
                            )
                    )
                    .padding(.horizontal, isSystemMode ? 10 : 3)
                    .scaleEffect(tapped ? 0.88 : 1.0)
                    .rotationEffect(.degrees(tapped ? -8 : 0))

                if !resolvedIsDark, !isSystemMode {
                    Spacer()
                }
            }
            .frame(width: 30, height: 26)
        }
        .frame(width: 30, height: 26)
        .scaleEffect(tapped ? 0.94 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                tapped = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.70)) {
                    tapped = false
                    appTheme.wrappedValue = appTheme.wrappedValue.next
                }
            }
        }
    }

    private var thumbColor: Color {
        resolvedIsDark
            ? Color(red: 0.98, green: 0.55, blue: 0.20)
            : Color(red: 0.95, green: 0.42, blue: 0.11)
    }
}

#Preview("System Light") {
    ThemeToggleButton(appTheme: .constant(.system), resolvedIsDark: false)
        .padding()
}

#Preview("System Dark") {
    ThemeToggleButton(appTheme: .constant(.system), resolvedIsDark: true)
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Manual Light") {
    ThemeToggleButton(appTheme: .constant(.light), resolvedIsDark: false)
        .padding()
}

#Preview("Manual Dark") {
    ThemeToggleButton(appTheme: .constant(.dark), resolvedIsDark: true)
        .padding()
        .preferredColorScheme(.dark)
}
