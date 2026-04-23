//
//  WorkspaceModels.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

enum WorkspacePalette {
  static func shellTop(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.surface.opacity(0.92) : ThemeColor.backgroundSecondary.opacity(0.94)
  }

  static func shellBottom(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.backgroundPrimary : ThemeColor.backgroundPrimary.opacity(0.94)
  }

  static func shellStroke(for colorScheme: ColorScheme) -> Color {
    ThemeColor.chromeStroke(for: colorScheme)
  }

  static func sidebarBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.surface.opacity(0.74) : ThemeColor.backgroundSecondary.opacity(0.78)
  }

  static func sidebarSelection(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.accent300.opacity(0.42) : ThemeColor.subtlePanelFill(for: colorScheme)
  }

  static func panelBackground(for colorScheme: ColorScheme) -> Color {
    ThemeColor.panelFill(for: colorScheme)
  }

  static func panelSecondary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.panelSecondaryFill(for: colorScheme) : ThemeColor.subtlePanelFill(for: colorScheme)
  }

  static func cardStroke(for colorScheme: ColorScheme) -> Color {
    ThemeColor.elevatedStroke(for: colorScheme)
  }

  static let primaryText = ThemeColor.textPrimary
  static let secondaryText = ThemeColor.textSecondary
  static func tertiaryText(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.neutral300.opacity(0.74) : ThemeColor.neutral500.opacity(0.92)
  }

  static let accent = ThemeColor.accent
  static func accentSoft(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.accent300.opacity(0.42) : ThemeColor.accent100.opacity(0.82)
  }

  static func border(for colorScheme: ColorScheme) -> Color {
    ThemeColor.chromeStroke(for: colorScheme)
  }

  static func shadow(for colorScheme: ColorScheme) -> Color {
    ThemeColor.elevatedShadow(for: colorScheme)
  }

  static let orbCore = ThemeColor.accent200
  static let orbEdge = ThemeColor.accent
  static let accentGradientStart = ThemeColor.accent300
  static let accentGradientEnd = ThemeColor.accent

  static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white : ThemeColor.neutral1000
  }

  static func primaryButtonForeground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.neutral1000 : Color.white
  }
}

enum WorkspaceNavigationPlacement {
  case primary
  case utility
}

enum WorkspaceDestination: String, CaseIterable, Hashable {
  case home = "Home"
  case threads = "Threads"
  case recents = "Recents"
  case agents = "Agents"
  case files = "Files"
  case share = "Share"
  case data = "Data"
  case help = "Help"
  case settings = "Settings"

  var systemImage: String {
    switch self {
    case .home:
      "house"
    case .threads:
      "bubble.left.and.bubble.right"
    case .recents:
      "clock.arrow.circlepath"
    case .agents:
      "sparkles.rectangle.stack"
    case .files:
      "folder"
    case .share:
      "point.3.connected.trianglepath"
    case .data:
      "cylinder.split.1x2"
    case .help:
      "headphones"
    case .settings:
      "gearshape"
    }
  }

  var navigationPlacement: WorkspaceNavigationPlacement {
    switch self {
    case .home, .threads, .recents, .agents, .files, .share, .data:
      .primary
    case .help, .settings:
      .utility
    }
  }

  var heroFirstLine: String {
    switch self {
    case .home:
      "Good Afternoon, Bambang"
    case .threads:
      "Pick up an"
    case .recents:
      "Bring back"
    case .agents:
      "Direct the"
    case .files:
      "Pull files into"
    case .share:
      "Coordinate faster"
    case .data:
      "Connect live"
    case .help:
      "Find the pattern"
    case .settings:
      "Tune the workspace"
    }
  }

  var heroSecondLineLeading: String {
    switch self {
    case .home:
      "What's on "
    case .threads:
      ""
    case .recents:
      ""
    case .agents:
      ""
    case .files:
      ""
    case .share:
      ""
    case .data:
      ""
    case .help:
      ""
    case .settings:
      ""
    }
  }

  var heroAccentText: String {
    switch self {
    case .home:
      "your mind?"
    case .threads:
      "active thread"
    case .recents:
      "recent context"
    case .agents:
      "right specialist"
    case .files:
      "the workspace"
    case .share:
      "with others"
    case .data:
      "project data"
    case .help:
      "that fits"
    case .settings:
      "to your flow"
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
    case .home:
      "Ask AI a question or make a request..."
    case .threads:
      "Describe the thread you want to continue..."
    case .recents:
      "Ask to reopen a recent direction..."
    case .agents:
      "Tell OpenSpace which specialist you need..."
    case .files:
      "Describe the file or reference you want to attach..."
    case .share:
      "Draft a share-ready message or invite note..."
    case .data:
      "Ask for a summary from your connected project data..."
    case .help:
      "Ask how this workspace should help next..."
    case .settings:
      "Describe the behavior you want to tune..."
    }
  }
}

enum WorkspaceModel: String, CaseIterable, Identifiable {
  case chatGPT4o = "ChatGPT 4o"
  case openSpaceFocus = "OpenSpace Focus"
  case gpt5Reasoning = "GPT-5 Reasoning"

  var id: String { rawValue }
}

enum WorkspaceWritingStyle: String, CaseIterable, Identifiable {
  case balanced = "Balanced"
  case concise = "Concise"
  case strategic = "Strategic"
  case exploratory = "Exploratory"

  var id: String { rawValue }
}

enum WorkspaceQuickPrompt: String, CaseIterable, Hashable, Identifiable {
  case toDoList = "Write a to-do list for a personal project"
  case emailReply = "Generate an email to reply to a job offer"
  case articleSummary = "Summarize this article in one paragraph"
  case technicalExplain = "How does AI work in a technical capacity"

  var id: String { rawValue }

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

struct WorkspaceViewBindings {
  let selectedDestination: Binding<WorkspaceDestination>
  let selectedModel: Binding<WorkspaceModel>
  let selectedPrompt: Binding<String>
  let selectedWritingStyle: Binding<WorkspaceWritingStyle>
  let citationEnabled: Binding<Bool>
  let highlightedQuickPrompt: Binding<WorkspaceQuickPrompt?>
  let isPromptFocused: FocusState<Bool>.Binding
  let replayOnboarding: () -> Void
}
