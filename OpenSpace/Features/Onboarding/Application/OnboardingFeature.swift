import ComposableArchitecture
import Foundation

struct OnboardingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var currentPage = 0
        var selectedPromptIndex = 0
        var queuedPromptCount = 2
        var reasoningLevel = 0.62
        var pairingConfirmed = true
        var isFinished = false

        var totalPages: Int { OnboardingPage.all.count }
        var isLastPage: Bool { currentPage >= totalPages - 1 }
        var currentPageData: OnboardingPage {
            let safeIndex = min(max(currentPage, 0), totalPages - 1)
            return OnboardingPage.all[safeIndex]
        }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case onboardingAlreadyCompleted(Bool)
        case nextTapped
        case previousTapped
        case pageSelected(Int)
        case finishTapped
        case skipTapped
        case promptChipTapped(Int)
        case addQueuedPromptTapped
        case reasoningLevelChanged(Double)
        case pairingToggleTapped
    }

    @Dependency(\.onboardingRepository) var onboardingRepository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [onboardingRepository] send in
                    do {
                        let completed = try await onboardingRepository.isOnboardingCompleted()
                        await send(.onboardingAlreadyCompleted(completed))
                    } catch {
                        await send(.onboardingAlreadyCompleted(false))
                    }
                }

            case let .onboardingAlreadyCompleted(completed):
                state.isFinished = completed
                return .none

            case .nextTapped:
                state.currentPage = min(state.currentPage + 1, state.totalPages - 1)
                return .none

            case .previousTapped:
                state.currentPage = max(state.currentPage - 1, 0)
                return .none

            case let .pageSelected(index):
                state.currentPage = min(max(index, 0), state.totalPages - 1)
                return .none

            case .finishTapped:
                state.isFinished = true
                return .run { [onboardingRepository] _ in
                    try? await onboardingRepository.completeOnboarding()
                }

            case .skipTapped:
                state.currentPage = state.totalPages - 1
                return .none

            case let .promptChipTapped(index):
                state.selectedPromptIndex = min(max(index, 0), OnboardingPromptOption.samples.count - 1)
                return .none

            case .addQueuedPromptTapped:
                state.queuedPromptCount = state.queuedPromptCount >= OnboardingPromptQueueItem.samples.count ? 2 : state.queuedPromptCount + 1
                return .none

            case let .reasoningLevelChanged(value):
                state.reasoningLevel = min(max(value, 0), 1)
                return .none

            case .pairingToggleTapped:
                state.pairingConfirmed.toggle()
                return .none
            }
        }
    }
}
