import ComposableArchitecture
import SwiftUI
#if os(iOS)
    import UIKit
#endif

// MARK: - OpenSpaceApp

@main
struct OpenSpaceApp: App {
    // MARK: Lifecycle

    init() {
        #if os(iOS)
            let accent = UIColor(hex: "FF7A30") ?? UIColor(ThemeColor.accent)
            UIView.appearance().tintColor = accent
            UIView.appearance().overrideUserInterfaceStyle = .dark
        #endif
    }

    // MARK: Internal

    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(store: store)
                .openSpaceTheme()
        }
    }
}
