import Foundation

enum AIProviderType: String, Sendable {
    case openAICompatible
    case anthropic
    case mock
}

struct AIProviderConfig: Sendable {
    let providerID: String
    let providerType: AIProviderType
    let baseURL: URL
    let apiKey: String
    let defaultModelID: String
}

actor AIProviderRegistry {
    static let shared = AIProviderRegistry()
    private var configs: [String: AIProviderConfig] = [:]

    func register(_ config: AIProviderConfig) {
        configs[config.providerID] = config
    }

    func client(for providerID: String?) -> any APIClientProtocol {
        guard let providerID, let config = configs[providerID] else {
            return MockStreamingClient.defaultClient()
        }
        switch config.providerType {
        case .openAICompatible:
            return OpenAICompatibleAdapter(config: config)
        case .anthropic:
            return AnthropicAdapter(config: config)
        case .mock:
            return MockStreamingClient.defaultClient()
        }
    }
}
