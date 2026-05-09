import ComposableArchitecture
import SwiftUI

struct OnboardingTopBar: View {
    let store: StoreOf<OnboardingFeature>
    var appTheme: Binding<AppTheme>
    var resolvedIsDark: Bool
    let palette: OpenSpacePalette

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 9) {
                ThemeToggleButton(appTheme: appTheme, resolvedIsDark: resolvedIsDark, palette: palette)

                VStack(alignment: .leading, spacing: 1) {
                    Text("OPENSPACE")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                    Text("AI ASSISTANCE")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(palette.textMuted)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("OpenSpace AI assistance")

            Spacer(minLength: 10)

            Text(String(format: "PG.%02d / %02d", store.currentPage + 1, store.totalPages))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(-0.24)
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Button {
                _ = store.send(.skipTapped)
            } label: {
                Text("SKIP")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(palette.surface.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(palette.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip onboarding")
        }
        .frame(height: 44)
    }
}
