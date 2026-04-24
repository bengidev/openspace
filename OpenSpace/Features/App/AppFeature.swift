import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
  @ObservableState
  struct State: Equatable {
    var onboarding = OnboardingFeature.State()
    var workspace = WorkspaceFeature.State()
    var hasCompletedOnboarding: Bool = false
  }
  
  @CasePathable
  enum Action {
    case onboarding(OnboardingFeature.Action)
    case workspace(WorkspaceFeature.Action)
    case onboardingCompleted
    case replayOnboarding
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.onboarding, action: \.onboarding) {
      OnboardingFeature()
    }
    Scope(state: \.workspace, action: \.workspace) {
      WorkspaceFeature()
    }
    Reduce { state, action in
      switch action {
      case .onboarding(.continueButtonTapped):
        state.hasCompletedOnboarding = true
        return .send(.workspace(.appeared))
        
      case .replayOnboarding:
        state.hasCompletedOnboarding = false
        return .none
        
      case .onboarding:
        return .none
        
      case .workspace(.replayOnboarding):
        state.hasCompletedOnboarding = false
        return .none
        
      case .workspace:
        return .none
        
      case .onboardingCompleted:
        return .none
      }
    }
  }
}
