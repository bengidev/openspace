import Foundation

enum ChatMessageRole: String, Equatable, Sendable, Codable {
    case user
    case assistant
    case system
    case tool
}

enum ChatMessageStatus: String, Equatable, Sendable, Codable {
    case streaming
    case complete
    case failed
}
