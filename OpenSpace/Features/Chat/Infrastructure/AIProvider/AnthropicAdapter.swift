import Foundation

struct AnthropicAdapter: APIClientProtocol, Sendable {
    let config: AIProviderConfig

    nonisolated func stream(request: ChatRequest) -> AsyncStream<StreamingEvent> {
        AsyncStream { continuation in
            Task {
                do {
                    let urlRequest = try makeURLRequest(for: request)
                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: urlRequest)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.yield(.error("Invalid response"))
                        continuation.finish()
                        return
                    }

                    guard httpResponse.statusCode == 200 else {
                        let body = try? await asyncBytes.reduce(into: Data()) { $0.append($1) }
                        let message = body.flatMap { String(data: $0, encoding: .utf8) } ?? "HTTP \(httpResponse.statusCode)"
                        continuation.yield(.error(message))
                        continuation.finish()
                        return
                    }

                    var buffer = ""
                    for try await byte in asyncBytes {
                        buffer.append(Character(UnicodeScalar(byte)))
                        if buffer.hasSuffix("\n\n") || buffer.hasSuffix("\r\n\r\n") {
                            processBuffer(buffer, continuation: continuation)
                            buffer = ""
                        }
                    }
                    if !buffer.isEmpty {
                        processBuffer(buffer, continuation: continuation)
                    }
                    continuation.yield(.done)
                    continuation.finish()
                } catch {
                    continuation.yield(.error(error.localizedDescription))
                    continuation.finish()
                }
            }
        }
    }

    private nonisolated func processBuffer(_ buffer: String, continuation: AsyncStream<StreamingEvent>.Continuation) {
        let lines = buffer.split(separator: "\n", omittingEmptySubsequences: true)
        var eventType = ""
        var eventData = ""
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("event: ") {
                eventType = String(trimmed.dropFirst(7))
            } else if trimmed.hasPrefix("data: ") {
                eventData = String(trimmed.dropFirst(6))
            }
        }

        guard let data = eventData.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }

        if eventType == "content_block_delta" || eventType == "message_delta" {
            if let delta = json["delta"] as? [String: Any],
               let text = delta["text"] as? String, !text.isEmpty {
                continuation.yield(.textDelta(text))
            }
        } else if eventType == "message_stop" {
            continuation.yield(.done)
        }
    }

    private nonisolated func makeURLRequest(for request: ChatRequest) throws -> URLRequest {
        let url = config.baseURL.appendingPathComponent("v1/messages")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(config.apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        urlRequest.timeoutInterval = 120

        var systemPrompt: String?
        let messages = request.messages.compactMap { msg -> [String: String]? in
            switch msg {
            case .system(let m):
                systemPrompt = m.content
                return nil
            default:
                var dict = msg.apiMessageDictionary
                if dict["role"] == ChatMessageRole.tool.rawValue {
                    dict["role"] = ChatMessageRole.user.rawValue
                }
                return dict
            }
        }

        var body: [String: Any] = [
            "model": request.modelID,
            "messages": messages,
            "max_tokens": 4096,
            "stream": true
        ]
        if let systemPrompt {
            body["system"] = systemPrompt
        }
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        return urlRequest
    }
}
