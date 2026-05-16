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

struct DynamicAPIClient: APIClientProtocol, Sendable {
    nonisolated func stream(request: ChatRequest) -> AsyncStream<StreamingEvent> {
        AsyncStream { continuation in
            let task = Task {
                let client = await AIProviderRegistry.shared.client(for: request.providerID)
                let stream = client.stream(request: request)
                for await event in stream {
                    continuation.yield(event)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient.wrap(DynamicAPIClient())
    static let testValue = APIClient(stream: { _ in AsyncStream { $0.finish() } })
    static let previewValue = APIClient(stream: { _ in AsyncStream { $0.finish() } })
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
