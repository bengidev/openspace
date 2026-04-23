//
//  WorkspacePreviewSupport.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

#if DEBUG
enum WorkspacePreviewSupport {
  static func context(
    variant: WorkspacePlatformVariant,
    size: CGSize,
    hasAppeared: Bool = true,
    reduceMotion: Bool = true
  ) -> WorkspaceRenderContext {
    WorkspaceRenderContext(
      variant: variant,
      containerSize: size,
      hasAppeared: hasAppeared,
      reduceMotion: reduceMotion
    )
  }

  @ViewBuilder
  static func preview<Content: View>(
    variant: WorkspacePlatformVariant,
    size: CGSize,
    hasAppeared: Bool = true,
    reduceMotion: Bool = true,
    selectedDestination: WorkspaceDestination = .home,
    selectedModel: WorkspaceModel = .chatGPT4o,
    selectedPrompt: String = "",
    selectedWritingStyle: WorkspaceWritingStyle = .balanced,
    citationEnabled: Bool = true,
    highlightedQuickPrompt: WorkspaceQuickPrompt? = nil,
    @ViewBuilder content: @escaping (WorkspaceRenderContext, WorkspaceViewBindings) -> Content
  ) -> some View {
    WorkspacePreviewHarness(
      context: context(
        variant: variant,
        size: size,
        hasAppeared: hasAppeared,
        reduceMotion: reduceMotion
      ),
      initialDestination: selectedDestination,
      initialModel: selectedModel,
      initialPrompt: selectedPrompt,
      initialWritingStyle: selectedWritingStyle,
      initialCitationEnabled: citationEnabled,
      initialHighlightedQuickPrompt: highlightedQuickPrompt,
      content: content
    )
  }
}

private struct WorkspacePreviewHarness<Content: View>: View {
  let context: WorkspaceRenderContext
  let initialDestination: WorkspaceDestination
  let initialModel: WorkspaceModel
  let initialPrompt: String
  let initialWritingStyle: WorkspaceWritingStyle
  let initialCitationEnabled: Bool
  let initialHighlightedQuickPrompt: WorkspaceQuickPrompt?
  let content: (WorkspaceRenderContext, WorkspaceViewBindings) -> Content

  @FocusState private var isPromptFocused: Bool
  @State private var selectedDestination: WorkspaceDestination
  @State private var selectedModel: WorkspaceModel
  @State private var selectedPrompt: String
  @State private var selectedWritingStyle: WorkspaceWritingStyle
  @State private var citationEnabled: Bool
  @State private var highlightedQuickPrompt: WorkspaceQuickPrompt?

  init(
    context: WorkspaceRenderContext,
    initialDestination: WorkspaceDestination,
    initialModel: WorkspaceModel,
    initialPrompt: String,
    initialWritingStyle: WorkspaceWritingStyle,
    initialCitationEnabled: Bool,
    initialHighlightedQuickPrompt: WorkspaceQuickPrompt?,
    @ViewBuilder content: @escaping (WorkspaceRenderContext, WorkspaceViewBindings) -> Content
  ) {
    self.context = context
    self.initialDestination = initialDestination
    self.initialModel = initialModel
    self.initialPrompt = initialPrompt
    self.initialWritingStyle = initialWritingStyle
    self.initialCitationEnabled = initialCitationEnabled
    self.initialHighlightedQuickPrompt = initialHighlightedQuickPrompt
    self.content = content
    _selectedDestination = State(initialValue: initialDestination)
    _selectedModel = State(initialValue: initialModel)
    _selectedPrompt = State(initialValue: initialPrompt)
    _selectedWritingStyle = State(initialValue: initialWritingStyle)
    _citationEnabled = State(initialValue: initialCitationEnabled)
    _highlightedQuickPrompt = State(initialValue: initialHighlightedQuickPrompt)
  }

  var body: some View {
    content(context, bindings)
  }

  private var bindings: WorkspaceViewBindings {
    WorkspaceViewBindings(
      selectedDestination: $selectedDestination,
      selectedModel: $selectedModel,
      selectedPrompt: $selectedPrompt,
      selectedWritingStyle: $selectedWritingStyle,
      citationEnabled: $citationEnabled,
      highlightedQuickPrompt: $highlightedQuickPrompt,
      isPromptFocused: $isPromptFocused,
      replayOnboarding: {}
    )
  }
}

extension View {
  func workspacePreviewSurface(size: CGSize) -> some View {
    ZStack {
      WorkspaceBackdrop(isAnimated: false)
      self
    }
    .frame(width: size.width, height: size.height)
    .openSpaceTheme()
  }
}
#endif
