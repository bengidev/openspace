import Foundation

struct WorkspaceThread: Identifiable, Equatable, Codable {
  let id: UUID
  var title: String
  var messages: [Message]
  var createdAt: Date
  var updatedAt: Date
  var model: WorkspaceModel
  
  init(
    id: UUID = UUID(),
    title: String,
    messages: [Message] = [],
    createdAt: Date = Date(),
    updatedAt: Date = Date(),
    model: WorkspaceModel = .chatGPT4o
  ) {
    self.id = id
    self.title = title
    self.messages = messages
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.model = model
  }
  
  static let mock = WorkspaceThread(
    id: UUID(),
    title: "Project Planning",
    messages: [
      Message(role: .user, content: "Help me plan my iOS app architecture"),
      Message(role: .assistant, content: "I'd recommend starting with a clear separation of concerns...")
    ],
    model: .chatGPT4o
  )
}

enum MessageRole: String, Codable, Equatable {
  case user
  case assistant
  case system
}

struct Message: Identifiable, Equatable, Codable {
  let id: UUID
  let role: MessageRole
  var content: String
  let createdAt: Date
  
  init(
    id: UUID = UUID(),
    role: MessageRole,
    content: String,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.role = role
    self.content = content
    self.createdAt = createdAt
  }
}
