import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct MockStreamingClientTests {
    @Test
    func defaultClientEmitsDeltasAndDone() async throws {
        let client = MockStreamingClient.default
        let request = ChatRequest(conversationID: UUID(), messages: [], modelID: "test")
        let stream = client.stream(request: request)

        var events: [StreamingEvent] = []
        for try await event in stream {
            events.append(event)
        }

        let expectedDeltas = MockStreamingClient.default.deltas.map { StreamingEvent.textDelta($0) }
        #expect(events == expectedDeltas + [.done])
    }

    @Test
    func customClientEmitsCorrectSequence() async throws {
        let client = MockStreamingClient(deltas: ["a", "bc", "d"], delayNanoseconds: 0)
        let request = ChatRequest(conversationID: UUID(), messages: [], modelID: "test")
        let stream = client.stream(request: request)

        var events: [StreamingEvent] = []
        for try await event in stream {
            events.append(event)
        }

        #expect(events == [.textDelta("a"), .textDelta("bc"), .textDelta("d"), .done])
    }
}
