import ComposableArchitecture
import Foundation

enum StreamingStatus: Equatable, Sendable {
    case idle
    case running
    case done
    case failed
}

@Reducer
struct ThreadEngine {
    @Dependency(APIClient.self) private var apiClient
    @Dependency(\.date.now) private var now
    @Dependency(\.uuid) private var uuid

    @ObservableState
    struct State: Equatable {
        var messages: [ChatMessage] = []
        var streamingStatus: StreamingStatus = .idle
        var currentPartialText: String = ""
    }

    @CasePathable
    enum Action: Equatable {
        case userMessageSent(ChatMessage)
        case streamingEvent(StreamingEvent)
        case streamCompleted
        case streamFailed(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .userMessageSent(let message):
                state.messages.append(message)
                state.streamingStatus = .running
                state.currentPartialText = ""

                let request = ChatRequest(
                    conversationID: message.id,
                    messages: state.messages,
                    modelID: "mock"
                )

                let stream = apiClient.stream(request)

                return .run { send in
                    for await event in stream {
                        await send(.streamingEvent(event))
                    }
                }
                .cancellable(id: "ThreadEngine.streaming", cancelInFlight: true)

            case .streamingEvent(let event):
                switch event {
                case .textDelta(let delta):
                    state.currentPartialText += delta
                    state.streamingStatus = .running

                    if let lastIndex = state.messages.indices.last,
                       case .text(var textMessage) = state.messages[lastIndex],
                       textMessage.role == .assistant {
                        textMessage.content = state.currentPartialText
                        textMessage.isComplete = false
                        state.messages[lastIndex] = .text(textMessage)
                    } else {
                        let assistantMessage = ChatMessage.text(
                            ChatTextMessage(
                                id: uuid(),
                                role: .assistant,
                                content: state.currentPartialText,
                                isComplete: false,
                                timestamp: now
                            )
                        )
                        state.messages.append(assistantMessage)
                    }

                case .done:
                    state.streamingStatus = .done
                    if let lastIndex = state.messages.indices.last,
                       case .text(var textMessage) = state.messages[lastIndex],
                       textMessage.role == .assistant {
                        textMessage.isComplete = true
                        state.messages[lastIndex] = .text(textMessage)
                    }
                    state.currentPartialText = ""

                case .error(let message):
                    return .send(.streamFailed(message))
                }
                return .none

            case .streamCompleted:
                state.streamingStatus = .done
                return .none

            case .streamFailed:
                state.streamingStatus = .failed
                return .none
            }
        }
    }
}
