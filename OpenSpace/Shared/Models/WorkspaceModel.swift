import Foundation

nonisolated enum WorkspaceModel: String, CaseIterable, Identifiable, Equatable, Codable, Sendable {
    case chatGPT4o = "ChatGPT 4o"
    case openSpaceFocus = "OpenSpace Focus"
    case gpt5Reasoning = "GPT-5 Reasoning"

    var id: String {
        rawValue
    }
}
