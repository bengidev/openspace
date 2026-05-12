import ComposableArchitecture
import SwiftUI

struct AppCore: Reducer {
    @ObservableState
    struct State: Equatable {
        var appTheme: AppTheme = .system
        var onboarding = OnboardingContainer.State()
        var home = HomeContainer.State()
    }

    @CasePathable
    enum Action: Equatable {
        case appDidAppear
        case appThemeLoaded(AppTheme)
        case appThemeChanged(AppTheme)
        case onboarding(OnboardingContainer.Action)
        case home(HomeContainer.Action)
    }

    @Dependency(\.appSettings) private var appSettings

    var body: some Reducer<State, Action> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingContainer()
        }

        Scope(state: \.home, action: \.home) {
            HomeContainer()
        }

        Reduce { state, action in
            switch action {
            case .appDidAppear:
                return .merge(
                    .send(.appThemeLoaded(appSettings.loadTheme())),
                    .send(.onboarding(.onAppear))
                )

            case let .appThemeLoaded(theme):
                state.appTheme = theme
                return .none

            case let .appThemeChanged(theme):
                state.appTheme = theme
                return .run { [appSettings] _ in
                    appSettings.saveTheme(theme)
                }

            case .onboarding(.themeToggleTapped):
                let next = state.appTheme.next
                state.appTheme = next
                return .run { [appSettings] _ in
                    appSettings.saveTheme(next)
                }

            case .onboarding, .home:
                return .none
            }
        }
    }
}
