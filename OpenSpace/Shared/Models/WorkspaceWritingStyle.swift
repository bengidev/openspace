import Foundation

enum WorkspaceWritingStyle: String, CaseIterable, Identifiable, Equatable, Codable {
  case balanced = "Balanced"
  case concise = "Concise"
  case strategic = "Strategic"
  case exploratory = "Exploratory"

  var id: String { rawValue }
}
