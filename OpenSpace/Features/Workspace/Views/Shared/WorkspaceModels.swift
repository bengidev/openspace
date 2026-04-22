//
//  WorkspaceModels.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

enum WorkspacePalette {
  static let shellTop = Color(red: 0.97, green: 0.97, blue: 0.96)
  static let shellBottom = Color(red: 0.94, green: 0.94, blue: 0.93)
  static let shellStroke = Color.white.opacity(0.85)
  static let sidebarBackground = Color(red: 0.94, green: 0.94, blue: 0.93)
  static let sidebarSelection = Color.white.opacity(0.92)
  static let panelBackground = Color.white.opacity(0.96)
  static let panelSecondary = Color(red: 0.97, green: 0.97, blue: 0.96)
  static let cardStroke = Color(red: 0.90, green: 0.89, blue: 0.87)
  static let primaryText = Color(red: 0.15, green: 0.16, blue: 0.18)
  static let secondaryText = Color(red: 0.49, green: 0.49, blue: 0.51)
  static let tertiaryText = Color(red: 0.63, green: 0.63, blue: 0.65)
  static let accent = Color(red: 0.88, green: 0.58, blue: 0.28)
  static let accentSoft = Color(red: 0.98, green: 0.95, blue: 0.90)
  static let border = Color.black.opacity(0.06)
  static let shadow = Color.black.opacity(0.12)
}

enum WorkspaceSidebarSection: String {
  case create = "Create"
  case library = "Library"
  case support = "Support"
}

enum WorkspaceDestination: String, CaseIterable, Hashable {
  case textToImage = "Text to image"
  case sketchToImage = "Sketch to image"
  case imageToImage = "Image to image"
  case projects = "Projects"
  case gallery = "Gallery"
  case favorites = "Favorites"
  case history = "History"
  case help = "Help"
  case settings = "Settings"

  var systemImage: String {
    switch self {
    case .textToImage:
      "text.alignleft"
    case .sketchToImage:
      "pencil.and.scribble"
    case .imageToImage:
      "photo.on.rectangle"
    case .projects:
      "folder"
    case .gallery:
      "square.grid.2x2"
    case .favorites:
      "star"
    case .history:
      "clock.arrow.circlepath"
    case .help:
      "questionmark.circle"
    case .settings:
      "gearshape"
    }
  }

  var section: WorkspaceSidebarSection {
    switch self {
    case .textToImage, .sketchToImage, .imageToImage:
      .create
    case .projects, .gallery, .favorites, .history:
      .library
    case .help, .settings:
      .support
    }
  }

  var subtitle: String {
    switch self {
    case .textToImage:
      "Turn a scene description into a cinematic visual."
    case .sketchToImage:
      "Refine rough sketches into polished concepts."
    case .imageToImage:
      "Transform references into a new visual direction."
    case .projects:
      "Organize ongoing explorations and keep iterations together."
    case .gallery:
      "Browse generated visuals and revisit stand-out frames."
    case .favorites:
      "Keep your strongest prompts and outputs close at hand."
    case .history:
      "Reopen previous sessions and continue where you left off."
    case .help:
      "Learn the workspace patterns and discover shortcuts."
    case .settings:
      "Fine-tune providers, defaults, and workspace preferences."
    }
  }

  var heroTitle: String {
    switch self {
    case .textToImage:
      "Good to see you, Bambang"
    case .sketchToImage:
      "Bring rough sketches to life"
    case .imageToImage:
      "Remix what already exists"
    case .projects:
      "Your workspace is taking shape"
    case .gallery:
      "A clean archive for your best generations"
    case .favorites:
      "Keep strong directions within reach"
    case .history:
      "Every iteration stays recoverable"
    case .help:
      "The workspace is designed to stay lightweight"
    case .settings:
      "Tune OpenSpace around your creative routine"
    }
  }

  var heroBody: String {
    switch self {
    case .textToImage:
      "Choose a prompt below or write your own to start shaping visuals with OpenSpace."
    case .sketchToImage:
      "Drop a sketch concept into the composer and decide how stylized or grounded the output should feel."
    case .imageToImage:
      "Start with a reference, adjust direction, and keep the next pass aligned with your intent."
    case .projects:
      "The shell now mirrors the reference layout, so future conversation and provider flows have a solid foundation."
    case .gallery:
      "This first workspace pass establishes hierarchy, navigation, and composition for richer asset browsing next."
    case .favorites:
      "Pin reusable prompts, preferred models, and notable outputs so the best work is easier to revisit."
    case .history:
      "Use the same composer surface to restart older explorations without losing the calm, focused layout."
    case .help:
      "The current build focuses on navigation, composition, and visual structure before real provider data arrives."
    case .settings:
      "Provider selection, workspace defaults, and credential screens can plug into this shell without redesigning it."
    }
  }

  var composerPlaceholder: String {
    switch self {
    case .textToImage:
      "Add prompt instructions"
    case .sketchToImage:
      "Describe how the sketch should be transformed"
    case .imageToImage:
      "Describe the new direction for the reference"
    case .projects:
      "Capture the direction for your next workspace thread"
    case .gallery:
      "Describe what you want to revisit or refine"
    case .favorites:
      "Write a reusable prompt worth keeping"
    case .history:
      "Summarize the thread you want to continue"
    case .help:
      "Ask what you want this workspace to support next"
    case .settings:
      "Describe the default behavior you want to tune"
    }
  }
}

enum WorkspaceModel: String, CaseIterable, Identifiable {
  case artboard3 = "ArtBoard 3"
  case lucidCanvas = "Lucid Canvas"
  case openSpaceVision = "OpenSpace Vision"

  var id: String { rawValue }
}

enum WorkspaceStyleChip: String, CaseIterable, Hashable {
  case highQuality = "High quality"
  case fourK = "4K"
  case cinematic = "Cinematic"
  case cleanEdges = "Clean edges"
}

enum WorkspaceQuickPrompt: String, CaseIterable, Hashable {
  case mysticalForest = "Mystical Forest Portal"
  case neonCity = "Neon City Streets"
  case lotusTemple = "Lotus Temple"
  case desertCastle = "Desert Castle"
  case lunarArchive = "Lunar Archive"
}

struct WorkspaceViewBindings {
  let selectedDestination: Binding<WorkspaceDestination>
  let selectedModel: Binding<WorkspaceModel>
  let selectedPrompt: Binding<String>
  let selectedStyleChips: Binding<Set<WorkspaceStyleChip>>
  let toneValue: Binding<Double>
  let isRandomized: Binding<Bool>
  let highlightedQuickPrompt: Binding<WorkspaceQuickPrompt?>
  let isPromptFocused: FocusState<Bool>.Binding
  let replayOnboarding: () -> Void
}
