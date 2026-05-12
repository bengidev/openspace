import ComposableArchitecture
import Foundation

struct AppSettingsClient {
    var loadTheme: @Sendable () -> AppTheme
    var saveTheme: @Sendable (AppTheme) -> Void
}

extension AppSettingsClient: DependencyKey {
    static let liveValue = AppSettingsClient(
        loadTheme: {
            guard
                let rawValue = UserDefaults.standard.string(forKey: "appTheme"),
                let theme = AppTheme(rawValue: rawValue)
            else {
                return .system
            }

            return theme
        },
        saveTheme: { theme in
            UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        }
    )

    static let testValue = AppSettingsClient(
        loadTheme: { .system },
        saveTheme: { _ in }
    )
}

extension DependencyValues {
    var appSettings: AppSettingsClient {
        get { self[AppSettingsClient.self] }
        set { self[AppSettingsClient.self] = newValue }
    }
}
