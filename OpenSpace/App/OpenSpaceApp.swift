import SwiftUI
import ComposableArchitecture

@main
struct OpenSpaceApp: App {
  let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  init() {
    #if os(iOS)
    let accent = UIColor(ThemeColor.accent)
    UIView.appearance().tintColor = accent
    #endif
  }

  var body: some Scene {
    WindowGroup {
      AppRootView(store: store)
        .openSpaceTheme()
    }
    #if os(macOS)
    .defaultSize(width: 1280, height: 820)
    .defaultPosition(.center)
    .windowToolbarStyle(.unifiedCompact)
    .windowResizability(.contentMinSize)
    #endif
  }
}
