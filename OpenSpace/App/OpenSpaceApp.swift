import ComposableArchitecture
import SwiftUI
import UIKit

// MARK: - OpenSpaceApp

@main
struct OpenSpaceApp: App {
    // MARK: Lifecycle

    init() {
        let accent = UIColor(hex: "FF7A30") ?? UIColor(ThemeColor.accent)
        UIView.appearance().tintColor = accent
        UIView.appearance().overrideUserInterfaceStyle = .dark
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
