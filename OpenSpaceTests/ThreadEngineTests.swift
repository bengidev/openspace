import ComposableArchitecture
import Foundation
import Testing

@testable import OpenSpace

@MainActor
struct ThreadEngineTests {
    @Test
    func sendMessageStartsStreamingAccumulatesTextAndMarksDone() async throws {
        let fixedTimestamp = Date(timeIntervalSince1970: 0)
        let userID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let assistantID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        let userMessage = ChatMessage.text(
            ChatTextMessage(
                id: userID,
                role: .user,
                content: "Hi",
                timestamp: fixedTimestamp
            )
        )

        let store = TestStore(initialState: ThreadEngine.State()) {
            ThreadEngine()
        } withDependencies: {
            $0.date.now = fixedTimestamp
            $0.uuid = .constant(assistantID)
            var apiClient = APIClient.testValue
            apiClient.stream = { _ in
                AsyncStream { continuation in
                    continuation.yield(.textDelta("H"))
                    continuation.yield(.textDelta("i"))
                    continuation.yield(.done)
                    continuation.finish()
                }
            }
            $0[APIClient.self] = apiClient
        }

        await store.send(.userMessageSent(userMessage)) {
            $0.messages = [userMessage]
            $0.streamingStatus = .running
            $0.currentPartialText = ""
        }

        await store.receive(.streamingEvent(.textDelta("H"))) {
            $0.currentPartialText = "H"
            let assistantMessage = ChatMessage.text(
                ChatTextMessage(
                    id: assistantID,
                    role: .assistant,
                    content: "H",
                    isComplete: false,
                    timestamp: fixedTimestamp
                )
            )
            $0.messages = [userMessage, assistantMessage]
        }

        await store.receive(.streamingEvent(.textDelta("i"))) {
            $0.currentPartialText = "Hi"
            let assistantMessage = ChatMessage.text(
                ChatTextMessage(
                    id: assistantID,
                    role: .assistant,
                    content: "Hi",
                    isComplete: false,
                    timestamp: fixedTimestamp
                )
            )
            $0.messages = [userMessage, assistantMessage]
        }

        await store.receive(.streamingEvent(.done)) {
            $0.streamingStatus = .done
            $0.currentPartialText = ""
            let assistantMessage = ChatMessage.text(
                ChatTextMessage(
                    id: assistantID,
                    role: .assistant,
                    content: "Hi",
                    isComplete: true,
                    timestamp: fixedTimestamp
                )
            )
            $0.messages = [userMessage, assistantMessage]
        }
    }

    @Test
    func streamFailureMarksFailed() async throws {
        let fixedTimestamp = Date(timeIntervalSince1970: 0)
        let userID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let assistantID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        let userMessage = ChatMessage.text(
            ChatTextMessage(
                id: userID,
                role: .user,
                content: "Test",
                timestamp: fixedTimestamp
            )
        )

        let store = TestStore(initialState: ThreadEngine.State()) {
            ThreadEngine()
        } withDependencies: {
            $0.date.now = fixedTimestamp
            $0.uuid = .constant(assistantID)
            var apiClient = APIClient.testValue
            apiClient.stream = { _ in
                AsyncStream { continuation in
                    continuation.yield(.error("Mock network failure"))
                    continuation.finish()
                }
            }
            $0[APIClient.self] = apiClient
        }

        await store.send(.userMessageSent(userMessage)) {
            $0.messages = [userMessage]
            $0.streamingStatus = .running
        }

        await store.receive(.streamingEvent(.error("Mock network failure")))

        await store.receive(.streamFailed("Mock network failure")) {
            $0.streamingStatus = .failed
        }
    }
}
