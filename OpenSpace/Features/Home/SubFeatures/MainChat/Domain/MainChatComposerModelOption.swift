import Foundation

enum ComposerModelOption: String, CaseIterable, Equatable, Identifiable, Sendable {
    case gpt54 = "gpt-5.4"
    case gpt55 = "gpt-5.5"
    case local = "local"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gpt54:
            return "GPT-5.4"
        case .gpt55:
            return "GPT-5.5"
        case .local:
            return "Local"
        }
    }

    var providerID: String? {
        switch self {
        case .gpt54, .gpt55:
            return "openai"
        case .local:
            return "local"
        }
    }

    var availableSpeedModes: [ComposerSpeedMode] {
        switch self {
        case .gpt54, .gpt55:
            return ComposerSpeedMode.allCases
        case .local:
            return []
        }
    }

    static func resolve(modelID: String?) -> ComposerModelOption? {
        guard let modelID else {
            return nil
        }
        return allCases.first { option in
            option.rawValue == modelID || option.title == modelID
        }
    }
}
