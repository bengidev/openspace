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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextTapped:
                state.currentPage = min(state.currentPage + 1, state.totalPages - 1)
                return .none

            case .previousTapped:
                state.currentPage = max(state.currentPage - 1, 0)
                return .none

            case let .pageSelected(index):
                state.currentPage = min(max(index, 0), state.totalPages - 1)
                return .none

            case .finishTapped, .skipTapped:
                state.isFinished = true
                return .none

            case let .promptChipTapped(index):
                state.selectedPromptIndex = min(max(index, 0), PromptOption.samples.count - 1)
                return .none

            case .addQueuedPromptTapped:
                state.queuedPromptCount = state.queuedPromptCount >= PromptQueueItem.samples.count ? 2 : state.queuedPromptCount + 1
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

struct OnboardingPage: Equatable, Identifiable {
    enum Model: Equatable {
        case encryptedPairing
        case ideaStudio
        case promptQueue
        case reasoningControl
    }

    let id: String
    let model: Model
    let indexLabel: String
    let eyebrow: String
    let headline: String
    let body: String
    let metric: String
    let command: String
    let shaderIntensity: Double
    let highlights: [FeatureHighlight]

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: "encrypted-pairing",
            model: .encryptedPairing,
            indexLabel: "SEC-01",
            eyebrow: "Encrypted pairing",
            headline: "End-to-end encrypted pairing and chats",
            body: "Pair trusted devices, keep local workspace context private, and open AI chats without leaking the conversation boundary.",
            metric: "E2E CHANNEL",
            command: "pair --device workspace --mode sealed",
            shaderIntensity: 0.78,
            highlights: [
                FeatureHighlight(title: "Local memory", detail: "Persists offline", symbol: "externaldrive.badge.checkmark"),
                FeatureHighlight(title: "Secure session", detail: "Rotates keys", symbol: "lock.shield"),
            ]
        ),
        OnboardingPage(
            id: "idea-studio",
            model: .ideaStudio,
            indexLabel: "AI-02",
            eyebrow: "Model workspace",
            headline: "Ask questions, write, and explore ideas with AI models",
            body: "OpenSpace turns prompts into a focused working surface for drafting, refactoring, research, and interface decisions.",
            metric: "MODEL STUDIO",
            command: "ask --model adaptive --context project",
            shaderIntensity: 0.55,
            highlights: [
                FeatureHighlight(title: "Design canvas", detail: "Native cards", symbol: "square.stack.3d.up"),
                FeatureHighlight(title: "AI assistance", detail: "Structured sessions", symbol: "sparkles"),
            ]
        ),
        OnboardingPage(
            id: "prompt-queue",
            model: .promptQueue,
            indexLabel: "RUN-03",
            eyebrow: "Queue control",
            headline: "Queue follow-up prompts while a turn is still running",
            body: "Keep momentum by lining up the next question, test request, or implementation step before the current model turn finishes.",
            metric: "LIVE QUEUE",
            command: "queue append --while-running follow-up",
            shaderIntensity: 0.66,
            highlights: [
                FeatureHighlight(title: "TCA reducer", detail: "Explicit actions", symbol: "point.3.connected.trianglepath.dotted"),
                FeatureHighlight(title: "Run steering", detail: "Visible follow-ups", symbol: "arrow.triangle.branch"),
            ]
        ),
        OnboardingPage(
            id: "reasoning-controls",
            model: .reasoningControl,
            indexLabel: "THK-04",
            eyebrow: "Reasoning dial",
            headline: "Reasoning controls to tune how much thinking AI model uses",
            body: "Choose faster answers, balanced planning, or deeper reasoning before the AI model commits compute to the task.",
            metric: "THINK BUDGET",
            command: "model set reasoning --level balanced",
            shaderIntensity: 0.82,
            highlights: [
                FeatureHighlight(title: "Model controls", detail: "Adjust thinking", symbol: "slider.horizontal.3"),
                FeatureHighlight(title: "Human steering", detail: "User-set compute", symbol: "person.crop.circle.badge.checkmark"),
            ]
        ),
    ]
}

struct FeatureHighlight: Equatable, Identifiable {
    var id: String { title }
    let title: String
    let detail: String
    let symbol: String
}

struct PromptOption: Equatable, Identifiable {
    var id: String { prompt }
    let label: String
    let prompt: String

    static let samples: [PromptOption] = [
        PromptOption(label: "ASK", prompt: "How should I structure the SwiftData model for this workflow?"),
        PromptOption(label: "WRITE", prompt: "Draft a concise SwiftUI view for the secure pairing step."),
        PromptOption(label: "EXPLORE", prompt: "Compare TCA actions for queued prompts and reasoning controls."),
    ]
}

struct PromptQueueItem: Equatable, Identifiable {
    enum Status: String, Equatable {
        case running = "RUNNING"
        case next = "NEXT"
        case queued = "QUEUED"
        case ready = "READY"
    }

    var id: String { title }
    let title: String
    let detail: String
    let status: Status

    static let samples: [PromptQueueItem] = [
        PromptQueueItem(title: "Map onboarding state", detail: "Reducer already owns current page", status: .running),
        PromptQueueItem(title: "Generate SwiftUI cards", detail: "No vertical scroll, compact content", status: .next),
        PromptQueueItem(title: "Persist completion", detail: "SwiftData writes local progress", status: .queued),
        PromptQueueItem(title: "Review model budget", detail: "Reasoning slider updates the run", status: .ready),
    ]
}
