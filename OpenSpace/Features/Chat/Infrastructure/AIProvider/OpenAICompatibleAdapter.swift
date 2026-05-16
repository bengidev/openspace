import Foundation

struct OpenAICompatibleAdapter: APIClientProtocol, Sendable {
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
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("data: ") else { continue }
            let dataStr = String(trimmed.dropFirst(6))
            guard dataStr != "[DONE]" else {
                continuation.yield(.done)
                return
            }
            guard let data = dataStr.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let first = choices.first,
                  let delta = first["delta"] as? [String: Any],
                  let content = delta["content"] as? String else {
                continue
            }
            if !content.isEmpty {
                continuation.yield(.textDelta(content))
            }
        }
    }

    private nonisolated func makeURLRequest(for request: ChatRequest) throws -> URLRequest {
        let url = config.baseURL.appendingPathComponent("v1/chat/completions")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        urlRequest.timeoutInterval = 120

        let messages = request.messages.map { $0.apiMessageDictionary }
        let body: [String: Any] = [
            "model": request.modelID,
            "messages": messages,
            "stream": true
        ]
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        return urlRequest
    }
}
