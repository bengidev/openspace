import ComposableArchitecture
import SwiftData
import SwiftUI

struct OnboardingContainerView: View {
    let modelContainer: ModelContainer

    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var store: StoreOf<OnboardingFeature>

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        _store = State(
            wrappedValue: Store(initialState: OnboardingFeature.State()) {
                OnboardingFeature()
            } withDependencies: {
                $0.onboardingRepository = SwiftDataOnboardingRepository(modelContainer: modelContainer)
            }
        )
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var body: some View {
        Group {
            if store.isFinished {
                HomeView()
            } else {
                OnboardingView(store: store, appTheme: $appTheme)
            }
        }
        .preferredColorScheme(resolvedColorScheme)
        .onAppear {
            store.send(.onAppear)
        }
    }
}
