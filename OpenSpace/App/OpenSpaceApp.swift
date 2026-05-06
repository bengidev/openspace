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
    }

    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .openSpaceTheme()
        }
    }
}
