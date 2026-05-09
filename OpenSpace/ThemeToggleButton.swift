import SwiftUI

struct ThemeToggleButton: View {
    var appTheme: Binding<AppTheme>
    var resolvedIsDark: Bool

    @State private var pulsePhase = false
    @State private var tapped = false

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

            // Ambient side dots
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 2, height: 2)
                    .padding(.leading, 5)

                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 2, height: 2)
                    .padding(.trailing, 5)
            }
            .frame(width: 30, height: 26)

            // Sliding thumb with glow
            HStack {
                if resolvedIsDark && !isSystemMode {
                    Spacer()
                }

                ZStack {
                    // Pulsing glow
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                        .fill(thumbColor)
                        .frame(width: 10, height: 20)
                        .blur(radius: 5)
                        .opacity(pulsePhase ? 0.55 : 0.25)
                        .animation(
                            .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true),
                            value: pulsePhase
                        )

                    // Main thumb
                    RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    thumbColor.opacity(0.95),
                                    thumbColor.opacity(0.80),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 10, height: 20)
                        .shadow(
                            color: thumbColor.opacity(isSystemMode ? 0.30 : 0.50),
                            radius: isSystemMode ? 2 : 4,
                            x: 0,
                            y: 2
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                                .stroke(
                                    isSystemMode
                                        ? Color.white.opacity(0.08)
                                        : Color.white.opacity(0.18),
                                    lineWidth: 0.5
                                )
                        )
                }
                .padding(.horizontal, isSystemMode ? 10 : 3)
                .scaleEffect(tapped ? 0.88 : 1.0)
                .rotationEffect(.degrees(tapped ? -8 : 0))

                if !resolvedIsDark && !isSystemMode {
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
        .onAppear {
            pulsePhase = true
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
