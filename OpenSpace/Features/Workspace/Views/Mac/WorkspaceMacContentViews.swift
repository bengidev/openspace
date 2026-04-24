//
//  WorkspaceMacContentViews.swift
//  OpenSpace
//
//  macOS-specific thin wrappers around shared content views.
//  All layout logic lives in WorkspaceRenderContext and WorkspaceSharedContentViews.
//

import SwiftUI

struct WorkspaceMacMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      WorkspaceMainContent(context: context, bindings: bindings)
        .frame(minHeight: context.minimumShellHeight, alignment: .topLeading)
    }
  }
}

#Preview("Mac Workspace Content") {
  WorkspacePreviewSupport.preview(
    variant: .mac,
    size: CGSize(width: 1280, height: 820),
    selectedDestination: .home,
    selectedPrompt: "Plan the next three steps for the release candidate.",
    highlightedQuickPrompt: .articleSummary
  ) { context, bindings in
    WorkspaceMacMainContent(context: context, bindings: bindings)
      .frame(width: 1160, height: context.minimumShellHeight, alignment: .topLeading)
      .padding(24)
  }
  .workspacePreviewSurface(size: CGSize(width: 1240, height: 820))
}
