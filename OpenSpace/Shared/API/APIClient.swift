import Foundation
import ComposableArchitecture

struct APIClient {
  var fetchThreads: () async throws -> [WorkspaceThread]
  var sendPrompt: (String, WorkspaceModel, WorkspaceWritingStyle) async throws -> WorkspaceThread
  var deleteThread: (UUID) async throws -> Void
  var fetchThread: (UUID) async throws -> WorkspaceThread
}

extension APIClient: DependencyKey {
  static let liveValue = APIClient(
    fetchThreads: {
      try await Task.sleep(for: .seconds(0.5))
      return [
        WorkspaceThread(title: "Project Planning", model: .chatGPT4o),
        WorkspaceThread(title: "Code Review", model: .gpt5Reasoning),
        WorkspaceThread(title: "Design Discussion", model: .openSpaceFocus)
      ]
    },
    sendPrompt: { prompt, model, style in
      try await Task.sleep(for: .seconds(0.8))
      let response = "Dummy response for: \"\(prompt)\" using \(model.rawValue) with \(style.rawValue) style."
      let thread = WorkspaceThread(
        title: String(prompt.prefix(40)),
        messages: [
          Message(role: .user, content: prompt),
          Message(role: .assistant, content: response)
        ],
        model: model
      )
      return thread
    },
    deleteThread: { id in
      try await Task.sleep(for: .seconds(0.3))
      print("Deleted thread: \(id)")
    },
    fetchThread: { id in
      try await Task.sleep(for: .seconds(0.4))
      return WorkspaceThread(id: id, title: "Fetched Thread", model: .chatGPT4o)
    }
  )
  
  static let testValue = APIClient(
    fetchThreads: { [] },
    sendPrompt: { prompt, _, _ in
      WorkspaceThread(title: prompt, messages: [Message(role: .assistant, content: "Test response")])
    },
    deleteThread: { _ in },
    fetchThread: { id in WorkspaceThread(id: id, title: "Test Thread") }
  )
}

extension DependencyValues {
  var apiClient: APIClient {
    get { self[APIClient.self] }
    set { self[APIClient.self] = newValue }
  }
}
