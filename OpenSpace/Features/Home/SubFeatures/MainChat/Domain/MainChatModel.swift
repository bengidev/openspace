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
        guard let modelID else { return nil }
        return allCases.first { $0.rawValue == modelID || $0.title == modelID }
    }
}

enum ComposerReasoningLevel: String, CaseIterable, Equatable, Identifiable, Sendable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

enum ComposerSpeedMode: String, CaseIterable, Equatable, Identifiable, Sendable {
    case standard
    case fast

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard:
            return "Standard"
        case .fast:
            return "Fast"
        }
    }

    var systemImage: String {
        switch self {
        case .standard:
            return "bolt"
        case .fast:
            return "bolt.fill"
        }
    }
}

struct ComposerContextUsage: Equatable, Sendable {
    var usedTokens: Int
    var tokenLimit: Int

    var usedFraction: Double {
        guard tokenLimit > 0 else { return 0 }
        return min(max(Double(usedTokens) / Double(tokenLimit), 0), 1)
    }

    var usedPercent: Int {
        Int((usedFraction * 100).rounded())
    }

    var remainingPercent: Int {
        max(100 - usedPercent, 0)
    }

    var usedTokensLabel: String {
        Self.compactTokenLabel(usedTokens)
    }

    var tokenLimitLabel: String {
        Self.compactTokenLabel(tokenLimit)
    }

    private static func compactTokenLabel(_ tokens: Int) -> String {
        if tokens >= 1_000 {
            return "\(tokens / 1_000)k"
        }
        return "\(tokens)"
    }
}

enum ComposerExecutionScope: String, CaseIterable, Equatable, Identifiable, Sendable {
    case local
    case hybrid
    case cloud

    var id: String { rawValue }

    var title: String {
        switch self {
        case .local:
            return "Local"
        case .hybrid:
            return "Hybrid"
        case .cloud:
            return "Cloud"
        }
    }
}

enum ComposerToolPolicy: String, CaseIterable, Equatable, Identifiable, Sendable {
    case review
    case auto
    case disabled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .review:
            return "Review"
        case .auto:
            return "Auto"
        case .disabled:
            return "Off"
        }
    }
}

enum ComposerBranch: String, CaseIterable, Equatable, Identifiable, Sendable {
    case main
    case plan
    case lab

    var id: String { rawValue }

    var title: String { rawValue }
}
