import Foundation

// MARK: - AIProvider

nonisolated struct AIProvider: Identifiable, Equatable, Codable, Sendable {
    // MARK: Lifecycle

    init(
        id: String,
        name: String,
        npm: String?,
        api: String?,
        env: [String],
        doc: String?
    ) {
        self.id = id
        self.name = name
        self.npm = npm
        self.api = api
        self.env = env
        self.doc = doc
    }

    // MARK: Internal

    let id: String
    let name: String
    let npm: String?
    let api: String?
    let env: [String]
    let doc: String?

    static func decodeCatalog(from data: Data) throws -> [AIProvider] {
        let payloads = try JSONDecoder().decode([String: ProviderPayload].self, from: data)
        return payloads.map { key, payload in
            AIProvider(
                id: payload.id ?? key,
                name: payload.name ?? payload.id ?? key,
                npm: payload.npm,
                api: payload.api,
                env: payload.env ?? [],
                doc: payload.doc
            )
        }
        .sortedByName()
    }
}

// MARK: - AIProviderConnectionMethod

nonisolated enum AIProviderConnectionMethod: String, CaseIterable, Identifiable, Sendable {
    case apiKey
    case webAuthentication

    var id: String { rawValue }

    var title: String {
        switch self {
        case .apiKey:
            "API key"
        case .webAuthentication:
            "Web auth"
        }
    }

    var description: String {
        switch self {
        case .apiKey:
            "Use a provider dashboard key."
        case .webAuthentication:
            "Authorize in browser."
        }
    }
}

// MARK: - AIProvider Helpers

extension AIProvider {
    nonisolated var availableConnectionMethods: [AIProviderConnectionMethod] {
        supportsWebAuthentication ? [.apiKey, .webAuthentication] : [.apiKey]
    }

    nonisolated var preferredAPIKeyName: String {
        env.first ?? "\(name.uppercased())_API_KEY"
    }

    nonisolated var webAuthenticationURL: URL? {
        switch id.lowercased() {
        case "openai":
            URL(string: "https://platform.openai.com")
        default:
            doc.flatMap(URL.init(string:))
        }
    }

    private nonisolated var supportsWebAuthentication: Bool {
        switch id.lowercased() {
        case "openai":
            true
        default:
            false
        }
    }
}

extension [AIProvider] {
    nonisolated func sortedByName() -> [AIProvider] {
        sorted { lhs, rhs in
            let comparison = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
            if comparison == .orderedSame {
                return lhs.id.localizedCaseInsensitiveCompare(rhs.id) == .orderedAscending
            }
            return comparison == .orderedAscending
        }
    }
}

// MARK: - ProviderPayload

private struct ProviderPayload: Decodable {
    let id: String?
    let name: String?
    let npm: String?
    let api: String?
    let env: [String]?
    let doc: String?
}
