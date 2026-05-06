import Foundation

// MARK: - OnboardingStep

struct OnboardingStep: Identifiable, Equatable, Sendable {
    let id: String
    let headline: String
    let body: String
    let symbol: String
    let features: [String]
    let pageType: PageType
}

enum PageType: Equatable, Sendable {
    case welcome
    case chat
    case organize
    case ready
}

// MARK: - Step Data

extension OnboardingStep {
    static let allSteps: [OnboardingStep] = [
        OnboardingStep(
            id: "welcome",
            headline: "Welcome to OpenSpace",
            body: "Your intelligent workspace for conversations, creation, and organization powered by AI.",
            symbol: "sparkles",
            features: ["AI Chat", "File Manager", "Smart Search"],
            pageType: .welcome
        ),
        OnboardingStep(
            id: "chat",
            headline: "Chat with AI",
            body: "Ask anything, write better, and explore ideas with advanced AI models right in your workspace.",
            symbol: "bubble.left.and.bubble.right",
            features: ["GPT-4o", "Claude 3", "Local Models"],
            pageType: .chat
        ),
        OnboardingStep(
            id: "organize",
            headline: "Organize Everything",
            body: "Keep conversations, files, and projects structured in one unified workspace.",
            symbol: "folder",
            features: ["Attachments", "Tags", "Search"],
            pageType: .organize
        ),
        OnboardingStep(
            id: "ready",
            headline: "Ready When You Are",
            body: "No complex setup. Jump in and start creating immediately.",
            symbol: "arrow.right.circle",
            features: ["No Setup", "Private", "Fast"],
            pageType: .ready
        ),
    ]
}
