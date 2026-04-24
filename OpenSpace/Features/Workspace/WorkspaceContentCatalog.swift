import Foundation

enum WorkspaceContentCatalog {
    struct DestinationContent {
        let heroFirstLine: String
        let heroSecondLineLeading: String
        let heroAccentText: String
        let heroBody: String
        let composerPlaceholder: String
    }

    static func content(for destination: WorkspaceDestination) -> DestinationContent {
        switch destination {
        case .home:
            .init(
                heroFirstLine: "Good Afternoon, Bambang",
                heroSecondLineLeading: "What's on ",
                heroAccentText: "your mind?",
                heroBody: "A calmer desktop workspace for planning, asking, and moving between threads without visual noise.",
                composerPlaceholder: "Ask AI a question or make a request..."
            )

        case .threads:
            .init(
                heroFirstLine: "Pick up an",
                heroSecondLineLeading: "",
                heroAccentText: "active thread",
                heroBody: "Recent conversations stay close, so continuing work takes one action instead of another full navigation pass.",
                composerPlaceholder: "Describe the thread you want to continue..."
            )

        case .recents:
            .init(
                heroFirstLine: "Bring back",
                heroSecondLineLeading: "",
                heroAccentText: "recent context",
                heroBody: "Reopen drafts, prompts, and references from the same centered workspace without breaking your train of thought.",
                composerPlaceholder: "Ask to reopen a recent direction..."
            )

        case .agents:
            .init(
                heroFirstLine: "Direct the",
                heroSecondLineLeading: "",
                heroAccentText: "right specialist",
                heroBody: "Move from a general chat into specialist support while keeping the same main composer and example-driven flow.",
                composerPlaceholder: "Tell OpenSpace which specialist you need..."
            )

        case .files:
            .init(
                heroFirstLine: "Pull files into",
                heroSecondLineLeading: "",
                heroAccentText: "the workspace",
                heroBody: "Attachments and project files enter the same composition surface, so context stays visible right where you ask.",
                composerPlaceholder: "Describe the file or reference you want to attach..."
            )

        case .share:
            .init(
                heroFirstLine: "Coordinate faster",
                heroSecondLineLeading: "",
                heroAccentText: "with others",
                heroBody: "Invite collaborators into the thread layer without turning the main canvas into a dashboard.",
                composerPlaceholder: "Draft a share-ready message or invite note..."
            )

        case .data:
            .init(
                heroFirstLine: "Connect live",
                heroSecondLineLeading: "",
                heroAccentText: "project data",
                heroBody: "Live project sources can sit behind a lighter shell, keeping the interface focused even as capability grows.",
                composerPlaceholder: "Ask for a summary from your connected project data..."
            )

        case .help:
            .init(
                heroFirstLine: "Find the pattern",
                heroSecondLineLeading: "",
                heroAccentText: "that fits",
                heroBody: "The shell favors one strong path forward, with support and recovery actions kept to the edges.",
                composerPlaceholder: "Ask how this workspace should help next..."
            )

        case .settings:
            .init(
                heroFirstLine: "Tune the workspace",
                heroSecondLineLeading: "",
                heroAccentText: "to your flow",
                heroBody: "Model defaults, citations, and workspace behaviors can evolve here without disturbing the main conversation rhythm.",
                composerPlaceholder: "Describe the behavior you want to tune..."
            )
        }
    }
}
