import ComposableArchitecture
import Foundation

protocol APIClientProtocol: Sendable {
    nonisolated func stream(request: ChatRequest) -> AsyncStream<StreamingEvent>
}

struct APIClient: Sendable {
    var stream: @Sendable (ChatRequest) -> AsyncStream<StreamingEvent>
}

extension APIClient {
    static func wrap(_ client: some APIClientProtocol) -> APIClient {
        APIClient(stream: { client.stream(request: $0) })
    }
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient.wrap(MockStreamingClient.default)
    static let testValue = APIClient(stream: { _ in AsyncStream { $0.finish() } })
    static let previewValue = APIClient(stream: { _ in AsyncStream { $0.finish() } })
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
