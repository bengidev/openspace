import Foundation

struct OnboardingPromptOption: Equatable, Sendable {
    var id: String { prompt }
    let label: String
    let prompt: String

    nonisolated init(label: String, prompt: String) {
        self.label = label
        self.prompt = prompt
    }

    static let samples: [OnboardingPromptOption] = [
        OnboardingPromptOption(label: "ASK", prompt: "How should I structure the memory model for this workflow?"),
        OnboardingPromptOption(label: "WRITE", prompt: "Draft a concise interface view for the secure pairing step."),
        OnboardingPromptOption(label: "EXPLORE", prompt: "Compare state actions for queued prompts and reasoning controls."),
    ]
}
