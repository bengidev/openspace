import Foundation

// MARK: - WorkspaceDestination

enum WorkspaceDestination: String, CaseIterable, Hashable, Identifiable, Equatable, Codable {
    case home
    case threads
    case recents
    case agents
    case files
    case share
    case data
    case help
    case settings

    // MARK: Internal

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue.capitalized
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .threads: "bubble.left.and.bubble.right"
        case .recents: "clock.arrow.circlepath"
        case .agents: "sparkles.rectangle.stack"
        case .files: "folder"
        case .share: "point.3.connected.trianglepath"
        case .data: "cylinder.split.1x2"
        case .help: "headphones"
        case .settings: "gearshape"
        }
    }

    var navigationPlacement: WorkspaceNavigationPlacement {
        switch self {
        case .help, .settings: .utility
        default: .primary
        }
    }
}

// MARK: - WorkspaceNavigationPlacement

enum WorkspaceNavigationPlacement: Equatable, Codable {
    case primary
    case utility
}

// MARK: - UI Extensions

extension WorkspaceDestination {
    var heroFirstLine: String {
        switch self {
        case .home: "Good Afternoon, Bambang"
        case .threads: "Pick up an"
        case .recents: "Bring back"
        case .agents: "Direct the"
        case .files: "Pull files into"
        case .share: "Coordinate faster"
        case .data: "Connect live"
        case .help: "Find the pattern"
        case .settings: "Tune the workspace"
        }
    }

    var heroSecondLineLeading: String {
        switch self {
        case .home: "What's on "
        default: ""
        }
    }

    var heroAccentText: String {
        switch self {
        case .home: "your mind?"
        case .threads: "active thread"
        case .recents: "recent context"
        case .agents: "right specialist"
        case .files: "the workspace"
        case .share: "with others"
        case .data: "project data"
        case .help: "that fits"
        case .settings: "to your flow"
        }
    }

    var heroBody: String {
        switch self {
        case .home:
            "A calmer desktop workspace for planning, asking, and moving between threads without visual noise."
        case .threads:
            "Recent conversations stay close, so continuing work takes one action instead of another full navigation pass."
        case .recents:
            "Reopen drafts, prompts, and references from the same centered workspace without breaking your train of thought."
        case .agents:
            "Move from a general chat into specialist support while keeping the same main composer and example-driven flow."
        case .files:
            "Attachments and project files enter the same composition surface, so context stays visible right where you ask."
        case .share:
            "Invite collaborators into the thread layer without turning the main canvas into a dashboard."
        case .data:
            "Live project sources can sit behind a lighter shell, keeping the interface focused even as capability grows."
        case .help:
            "The shell favors one strong path forward, with support and recovery actions kept to the edges."
        case .settings:
            "Model defaults, citations, and workspace behaviors can evolve here without disturbing the main conversation rhythm."
        }
    }

    var composerPlaceholder: String {
        switch self {
        case .home: "Ask AI a question or make a request..."
        case .threads: "Describe the thread you want to continue..."
        case .recents: "Ask to reopen a recent direction..."
        case .agents: "Tell OpenSpace which specialist you need..."
        case .files: "Describe the file or reference you want to attach..."
        case .share: "Draft a share-ready message or invite note..."
        case .data: "Ask for a summary from your connected project data..."
        case .help: "Ask how this workspace should help next..."
        case .settings: "Describe the behavior you want to tune..."
        }
    }
}
