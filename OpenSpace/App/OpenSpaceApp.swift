import SwiftUI
import ComposableArchitecture
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@main
struct OpenSpaceApp: App {
  let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  init() {
    #if os(iOS)
    let accent = UIColor(hex: "FF7A30") ?? UIColor(ThemeColor.accent)
    UIView.appearance().tintColor = accent
    UIView.appearance().overrideUserInterfaceStyle = .dark
    #elseif os(macOS)
    NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
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
