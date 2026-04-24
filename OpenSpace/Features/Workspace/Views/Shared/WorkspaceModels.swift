//
//  WorkspaceModels.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

// MARK: - WorkspaceQuickPrompt

enum WorkspaceQuickPrompt: String, CaseIterable, Hashable, Identifiable {
    case toDoList = "Write a to-do list for a personal project"
    case emailReply = "Generate an email to reply to a job offer"
    case articleSummary = "Summarize this article in one paragraph"
    case technicalExplain = "How does AI work in a technical capacity"

    var id: String {
        rawValue
    }

    var symbolName: String {
        switch self {
        case .toDoList:
            "person"
        case .emailReply:
            "envelope"
        case .articleSummary:
            "bubble.left"
        case .technicalExplain:
            "chevron.left.forwardslash.chevron.right"
        }
    }
}

// MARK: - WorkspaceViewBindings

struct WorkspaceViewBindings {
    var selectedDestination: Binding<WorkspaceDestination>
    var selectedModel: Binding<WorkspaceModel>
    var selectedPrompt: Binding<String>
    var selectedWritingStyle: Binding<WorkspaceWritingStyle>
    var citationEnabled: Binding<Bool>
    var highlightedQuickPrompt: Binding<WorkspaceQuickPrompt?>
    var isPromptFocused: FocusState<Bool>.Binding
    var sendPrompt: () -> Void
    var quickPromptTapped: (WorkspaceQuickPrompt) -> Void
    var replayOnboarding: () -> Void
}
