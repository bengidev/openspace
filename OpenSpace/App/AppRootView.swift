import ComposableArchitecture
import SwiftUI

struct AppRootView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                WorkspaceView(
                    store: store.scope(state: \.workspace, action: \.workspace)
                )
            } else {
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding),
                    onContinue: {
                        store.send(.onboarding(.continueButtonTapped))
                    }
                )
            }
        }
    }
}

#Preview("App Root - Onboarding") {
    AppRootView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .openSpaceTheme()
}

#Preview("App Root - Workspace") {
    AppRootView(
        store: Store(initialState: AppFeature.State(hasCompletedOnboarding: true)) {
            AppFeature()
        }
    )
    .openSpaceTheme()
}
