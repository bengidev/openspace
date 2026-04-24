import ComposableArchitecture
import SwiftUI

struct OnboardingFeature: Reducer {
  struct State: Equatable {
    var hasAppeared: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    
    #if os(macOS)
    var hasConfiguredWindow: Bool = false
    #endif
  }
  
  enum Action {
    case appeared
    case continueButtonTapped
    case dismissError
    
    // Optional: pre-load workspace data during onboarding
    case preloadData
    case preloadResponse(Result<[WorkspaceThread], Error>)
  }
  
  @Dependency(\.apiClient) var apiClient
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .appeared:
        guard !state.hasAppeared else { return .none }
        state.hasAppeared = true
        return .none
        
      case .continueButtonTapped:
        return .none
        
      case .dismissError:
        state.errorMessage = nil
        return .none
        
      case .preloadData:
        state.isLoading = true
        return .run { send in
          await send(.preloadResponse(Result {
            try await apiClient.fetchThreads()
          }))
        }
        
      case let .preloadResponse(.success):
        state.isLoading = false
        return .none
        
      case let .preloadResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
      }
    }
  }
}
