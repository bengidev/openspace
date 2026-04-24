//
//  WorkspaceIOSContentViews.swift
//  OpenSpace
//
//  iOS-specific thin wrappers around shared content views.
//  All layout logic lives in WorkspaceRenderContext and WorkspaceSharedContentViews.
//

import SwiftUI

struct WorkspaceIOSMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceMainContent(context: context, bindings: bindings)
  }
}

#Preview("iPhone Workspace Content") {
  WorkspacePreviewSupport.preview(
    variant: .ios,
    size: CGSize(width: 390, height: 844),
    selectedDestination: .home,
    selectedPrompt: "Draft a short update for the product review thread.",
    highlightedQuickPrompt: .toDoList
  ) { context, bindings in
    WorkspaceIOSMainContent(context: context, bindings: bindings)
      .frame(width: 390, height: context.minimumShellHeight, alignment: .topLeading)
  }
  .workspacePreviewSurface(size: CGSize(width: 390, height: 844))
}
