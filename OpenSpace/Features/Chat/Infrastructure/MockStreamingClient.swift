import Foundation

struct MockStreamingClient: APIClientProtocol, Sendable {
    let deltas: [String]
    let delayNanoseconds: UInt64
    let thinkingDelayNanoseconds: UInt64

    init(
        deltas: [String],
        delayNanoseconds: UInt64,
        thinkingDelayNanoseconds: UInt64 = 0
    ) {
        self.deltas = deltas
        self.delayNanoseconds = delayNanoseconds
        self.thinkingDelayNanoseconds = thinkingDelayNanoseconds
    }

    nonisolated func stream(request: ChatRequest) -> AsyncStream<StreamingEvent> {
        AsyncStream { continuation in
            Task {
                if self.thinkingDelayNanoseconds > 0 {
                    try? await Task.sleep(nanoseconds: self.thinkingDelayNanoseconds)
                }
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
        delayNanoseconds: 40_000_000, // 40ms per char — visible typing effect
        thinkingDelayNanoseconds: 1_500_000_000 // 1.5s thinking delay before first token
    )
}
