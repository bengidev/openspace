import Foundation

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
        guard tokenLimit > 0 else {
            return 0
        }
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
