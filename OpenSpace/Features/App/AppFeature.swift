import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
  struct State: Equatable {
    var onboarding = OnboardingFeature.State()
    var workspace = WorkspaceFeature.State()
    var hasCompletedOnboarding: Bool = false
  }
  
  enum Action {
    case onboarding(OnboardingFeature.Action)
    case workspace(WorkspaceFeature.Action)
    case onboardingCompleted
    case replayOnboarding
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.onboarding, action: /Action.onboarding) {
      OnboardingFeature()
    }
    Scope(state: \.workspace, action: /Action.workspace) {
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
