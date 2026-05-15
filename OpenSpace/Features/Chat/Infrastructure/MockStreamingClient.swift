import Foundation

struct MockStreamingClient: APIClientProtocol, Sendable {
    let deltas: [String]
    let delayNanoseconds: UInt64

    nonisolated func stream(request: ChatRequest) -> AsyncStream<StreamingEvent> {
        AsyncStream { continuation in
            Task {
                for delta in self.deltas {
                    if self.delayNanoseconds > 0 {
                        try? await Task.sleep(nanoseconds: self.delayNanoseconds)
                    }
                    continuation.yield(.textDelta(delta))
                }
                continuation.yield(.done)
                continuation.finish()
            }
        }
    }
}

extension MockStreamingClient {
    static let `default` = MockStreamingClient(
        deltas: Array("Hello! I'm a mock assistant.").map(String.init),
        delayNanoseconds: 40_000_000 // 40ms per char — visible typing effect
    )
}
