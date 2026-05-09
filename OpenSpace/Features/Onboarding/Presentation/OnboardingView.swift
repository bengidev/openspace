import ComposableArchitecture
import Foundation
import SwiftUI

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    var appTheme: Binding<AppTheme>

    @Environment(\.colorScheme) private var colorScheme

    private var resolvedIsDark: Bool {
        switch appTheme.wrappedValue {
        case .system:
            return colorScheme == .dark
        case .light:
            return false
        case .dark:
            return true
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let palette = OpenSpacePalette.resolve(colorScheme)
            let size = proxy.size
            let compactHeight = size.height < 760
            let horizontalPadding = min(max(size.width * 0.055, 20), 36)
            let visualHeight = max(compactHeight ? 270 : 326, min(size.height * (compactHeight ? 0.39 : 0.43), 390))

            ZStack {
                palette.background
                    .ignoresSafeArea()

                PixelGridBackground(
                    palette: palette,
                    spacing: compactHeight ? 18 : 22,
                    dotSize: 1.0,
                    opacity: palette.isDark ? 0.06 : 0.04
                )
                .ignoresSafeArea()

                DiagonalHatchPattern(
                    palette: palette,
                    spacing: 10,
                    opacity: palette.isDark ? 0.10 : 0.04
                )
                .ignoresSafeArea()

                VStack(spacing: compactHeight ? 12 : 18) {
                    OnboardingTopBar(
                        store: store,
                        appTheme: appTheme,
                        resolvedIsDark: resolvedIsDark,
                        palette: palette
                    )

                    OnboardingFeaturePageView(
                        page: store.currentPageData,
                        visualHeight: visualHeight,
                        palette: palette,
                        pairingConfirmed: store.pairingConfirmed,
                        selectedPromptIndex: store.selectedPromptIndex,
                        queuedPromptCount: store.queuedPromptCount,
                        reasoningLevel: $store.reasoningLevel.sending(\.reasoningLevelChanged),
                        onPairingToggle: { _ = store.send(.pairingToggleTapped) },
                        onPromptSelected: { _ = store.send(.promptChipTapped($0)) },
                        onAddQueuedPrompt: { _ = store.send(.addQueuedPromptTapped) }
                    )
                    .id(store.currentPageData.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )

                    OnboardingBottomNavigation(store: store, palette: palette)
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, compactHeight ? 8 : 12)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom + 10, 18))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sensoryFeedback(.selection, trigger: store.currentPage)
        }
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        },
        appTheme: .constant(.system)
    )
}
