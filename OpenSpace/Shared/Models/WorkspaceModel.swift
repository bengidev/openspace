import Foundation

enum WorkspaceModel: String, CaseIterable, Identifiable, Equatable, Codable {
  case chatGPT4o = "ChatGPT 4o"
  case openSpaceFocus = "OpenSpace Focus"
  case gpt5Reasoning = "GPT-5 Reasoning"

  var id: String { rawValue }
}
