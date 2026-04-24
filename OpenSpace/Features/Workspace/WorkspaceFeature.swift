@preconcurrency import ComposableArchitecture
import Foundation

struct WorkspaceFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedDestination = WorkspaceDestination.home
        var selectedModel = WorkspaceModel.chatGPT4o
        var selectedPrompt = ""
        var selectedWritingStyle = WorkspaceWritingStyle.balanced
        var citationEnabled = true
        var highlightedQuickPrompt: WorkspaceQuickPrompt?
        var isPromptFocused = false
        var hasAppeared = false

        // API state
        var isLoading = false
        var threads = [WorkspaceThread]()
        var errorMessage: String?

        #if os(macOS)
            var hasConfiguredWindow = false
        #endif
    }

    @CasePathable
    enum Action {
        case destinationSelected(WorkspaceDestination)
        case modelSelected(WorkspaceModel)
        case promptChanged(String)
        case writingStyleSelected(WorkspaceWritingStyle)
        case citationToggled(Bool)
        case quickPromptTapped(WorkspaceQuickPrompt)
        case sendButtonTapped
        case promptSubmitted
        case promptFocused(Bool)
        case appeared
        case replayOnboarding

        // API
        case fetchThreads
        case threadsResponse(Result<[WorkspaceThread], Error>)
        case sendPromptResponse(Result<WorkspaceThread, Error>)
        case dismissError
    }

    @Dependency(APIClient.self) var apiClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .destinationSelected(destination):
                state.selectedDestination = destination
                if destination == .threads {
                    return .send(.fetchThreads)
                }
                return .none

            case let .modelSelected(model):
                state.selectedModel = model
                return .none

            case let .promptChanged(prompt):
                state.selectedPrompt = prompt
                if state.highlightedQuickPrompt?.rawValue != prompt {
                    state.highlightedQuickPrompt = nil
                }
                return .none

            case let .writingStyleSelected(style):
                state.selectedWritingStyle = style
                return .none

            case let .citationToggled(enabled):
                state.citationEnabled = enabled
                return .none

            case let .quickPromptTapped(prompt):
                state.highlightedQuickPrompt = prompt
                state.selectedPrompt = prompt.rawValue
                state.isPromptFocused = true
                return .none

            case .sendButtonTapped:
                guard !state.selectedPrompt.isEmpty else { return .none }
                return .send(.promptSubmitted)

            case .promptSubmitted:
                state.isLoading = true
                let prompt = state.selectedPrompt
                let model = state.selectedModel
                let style = state.selectedWritingStyle
                return .run { send in
                    await send(.sendPromptResponse(Result {
                        try await apiClient.sendPrompt(prompt, model, style)
                    }))
                }

            case let .promptFocused(focused):
                state.isPromptFocused = focused
                return .none

            case .appeared:
                guard !state.hasAppeared else { return .none }
                state.hasAppeared = true
                return .none

            case .replayOnboarding:
                return .none

            case .fetchThreads:
                state.isLoading = true
                return .run { send in
                    await send(.threadsResponse(Result {
                        try await apiClient.fetchThreads()
                    }))
                }

            case let .threadsResponse(.success(threads)):
                state.isLoading = false
                state.threads = threads
                return .none

            case let .threadsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .sendPromptResponse(.success(thread)):
                state.isLoading = false
                state.threads.insert(thread, at: 0)
                state.selectedPrompt = ""
                state.highlightedQuickPrompt = nil
                return .none

            case let .sendPromptResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
