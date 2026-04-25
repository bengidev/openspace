import ComposableArchitecture
import Foundation
import OSLog

// MARK: - APIClient

private nonisolated let apiClientLogger = Logger(subsystem: "io.github.bengidev.OpenSpace", category: "APIClient")

struct APIClient: Sendable {
    var fetchThreads: @Sendable () async throws -> [WorkspaceThread]
    var fetchProviders: @Sendable () async throws -> [AIProvider]
    var sendPrompt: @Sendable (String, AIProvider, WorkspaceWritingStyle) async throws -> WorkspaceThread
    var deleteThread: @Sendable (UUID) async throws -> Void
    var fetchThread: @Sendable (UUID) async throws -> WorkspaceThread
}

// MARK: DependencyKey

extension APIClient: DependencyKey {
    static var liveValue: APIClient {
        APIClient(
            fetchThreads: {
                try await Task.sleep(for: .seconds(0.5))
                return [
                    WorkspaceThread(title: "Project Planning", model: .chatGPT4o),
                    WorkspaceThread(title: "Code Review", model: .gpt5Reasoning),
                    WorkspaceThread(title: "Design Discussion", model: .openSpaceFocus),
                ]
            },
            fetchProviders: {
                let url = URL(string: "https://models.dev/api.json")!
                var request = URLRequest(url: url)
                request.setValue("OpenSpace/1.0", forHTTPHeaderField: "User-Agent")

                apiClientLogger.info("Fetching provider catalog from \(url.host ?? "unknown-host", privacy: .public)\(url.path, privacy: .public)")

                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    let httpResponse = response as? HTTPURLResponse
                    let statusCode = httpResponse?.statusCode ?? -1
                    let contentType = httpResponse?.value(forHTTPHeaderField: "Content-Type") ?? "unknown"

                    guard (200 ..< 300).contains(statusCode) else {
                        apiClientLogger
                            .error(
                                "Provider catalog request failed with HTTP \(statusCode, privacy: .public); contentType=\(contentType, privacy: .public); bytes=\(data.count, privacy: .public)"
                            )
                        throw APIClientError.unexpectedStatusCode(statusCode)
                    }

                    do {
                        let providers = try AIProvider.decodeCatalog(from: data)
                        apiClientLogger
                            .info(
                                "Provider catalog decoded successfully; providers=\(providers.count, privacy: .public); bytes=\(data.count, privacy: .public); contentType=\(contentType, privacy: .public)"
                            )
                        return providers
                    } catch {
                        let errorType = String(reflecting: type(of: error))
                        apiClientLogger
                            .error(
                                "Provider catalog decode failed; errorType=\(errorType, privacy: .public); error=\(error.localizedDescription, privacy: .public); bytes=\(data.count, privacy: .public); contentType=\(contentType, privacy: .public)"
                            )
                        throw error
                    }
                } catch {
                    let errorType = String(reflecting: type(of: error))
                    apiClientLogger
                        .error("Provider catalog fetch failed; errorType=\(errorType, privacy: .public); error=\(error.localizedDescription, privacy: .public)")
                    throw error
                }
            },
            sendPrompt: { prompt, provider, style in
                try await Task.sleep(for: .seconds(0.8))
                let response = "Dummy response for: \"\(prompt)\" using \(provider.name) with \(style.rawValue) style."
                return WorkspaceThread(
                    title: String(prompt.prefix(40)),
                    messages: [
                        Message(role: .user, content: prompt),
                        Message(role: .assistant, content: response),
                    ]
                )
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
    }

    static var testValue: APIClient {
        APIClient(
            fetchThreads: { [] },
            fetchProviders: { [] },
            sendPrompt: { prompt, _, _ in
                WorkspaceThread(title: prompt, messages: [Message(role: .assistant, content: "Test response")])
            },
            deleteThread: { _ in },
            fetchThread: { id in WorkspaceThread(id: id, title: "Test Thread") }
        )
    }
}

// MARK: - APIClientError

enum APIClientError: Error, Equatable {
    case unexpectedStatusCode(Int)
}

extension APIClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .unexpectedStatusCode(statusCode):
            "Models.dev returned HTTP status \(statusCode)."
        }
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
