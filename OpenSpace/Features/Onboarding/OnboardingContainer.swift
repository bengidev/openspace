import ComposableArchitecture
import SwiftUI

struct OnboardingContainerView: View {
    @Bindable var store: StoreOf<OnboardingContainer>
    
    var body: some View {
        OnboardingView(
            store: store.scope(state: \.flow, action: \.flow),
            onThemeToggle: { store.send(.themeToggleTapped) }
        )
    }
}

@Reducer
struct OnboardingContainer {
    @ObservableState
    struct State: Equatable {
        var isFinished = false
        var flow = OnboardingFlowState()
    }
    
    @CasePathable
    enum Action: Equatable {
        case onAppear
        case finishTapped
        case skipTapped
        case themeToggleTapped
        case flow(OnboardingFlowAction)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.flow, action: \.flow) {
            OnboardingFlow()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.flow(.onAppear))
            case .finishTapped:
                return .send(.flow(.finishTapped))
            case .skipTapped:
                return .send(.flow(.skipTapped))
            case .themeToggleTapped:
                return .none
            case let .flow(.onboardingAlreadyCompleted(completed)):
                state.isFinished = completed
                return .none
            case .flow(.finishTapped):
                state.isFinished = true
                return .none
            case .flow(.themeToggleTapped):
                return .send(.themeToggleTapped)
            case .flow:
                return .none
            }
        }
    }
}

#Preview {
    OnboardingContainerView(
        store: Store(initialState: OnboardingContainer.State()) {
            OnboardingContainer()
        }
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
