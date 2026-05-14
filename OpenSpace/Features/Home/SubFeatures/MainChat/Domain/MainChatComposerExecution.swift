import Foundation

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
