import Foundation

// MARK: - QuickPrompt

struct QuickPrompt: Identifiable, Hashable, Equatable, Codable {
    let id: String
    let title: String
    let symbolName: String
    let promptText: String
}

extension QuickPrompt {
    static let toDoList = QuickPrompt(
        id: "to-do-list",
        title: "Write a to-do list for a personal project",
        symbolName: "person",
        promptText: "Write a to-do list for a personal project"
    )

    static let emailReply = QuickPrompt(
        id: "email-reply",
        title: "Generate an email to reply to a job offer",
        symbolName: "envelope",
        promptText: "Generate an email to reply to a job offer"
    )

    static let articleSummary = QuickPrompt(
        id: "article-summary",
        title: "Summarize this article in one paragraph",
        symbolName: "bubble.left",
        promptText: "Summarize this article in one paragraph"
    )

    static let technicalExplain = QuickPrompt(
        id: "technical-explain",
        title: "How does AI work in a technical capacity",
        symbolName: "chevron.left.forwardslash.chevron.right",
        promptText: "How does AI work in a technical capacity"
    )

    static let all: [QuickPrompt] = [.toDoList, .emailReply, .articleSummary, .technicalExplain]
}
