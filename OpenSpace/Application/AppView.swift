import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppCore>

    @Environment(\.colorScheme) private var systemColorScheme

    private var resolvedColorScheme: ColorScheme? {
        switch store.appTheme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var body: some View {
        let palette = OpenSpacePalette.resolve(resolvedColorScheme ?? systemColorScheme)

        Group {
            if store.onboarding.isFinished {
                HomeContainerView(store: store.scope(state: \.home, action: \.home))
            } else {
                OnboardingContainerView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            }
        }
        .environment(\.palette, palette)
        .environment(\.appTheme, store.appTheme)
        .preferredColorScheme(resolvedColorScheme)
        .onAppear {
            store.send(.appDidAppear)
        }
    }
}
