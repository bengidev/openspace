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
        #if os(macOS)
          .frame(minWidth: 640, idealWidth: 1120, minHeight: 520, idealHeight: 760)
        #endif
      } else {
        OnboardingView(
          store: store.scope(state: \.onboarding, action: \.onboarding),
          onContinue: {
            store.send(.onboarding(.continueButtonTapped))
          }
        )
        #if os(macOS)
          .frame(minWidth: 760, idealWidth: 1120, minHeight: 560, idealHeight: 720)
        #endif
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
