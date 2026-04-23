//
//  WorkspaceMacView.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceMacView: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceMacShell(context: context, bindings: bindings)
      .frame(maxWidth: .infinity, minHeight: context.preferredShellHeight, alignment: .center)
      .accessibilityIdentifier("workspace.mac.content")
  }
}

#Preview("Workspace Mac Content") {
  WorkspacePreviewSupport.preview(
    variant: .mac,
    size: CGSize(width: 1280, height: 820)
  ) { context, bindings in
    WorkspaceMacView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 1280, height: 820))
}

#Preview("Workspace Mac Threads") {
  WorkspacePreviewSupport.preview(
    variant: .mac,
    size: CGSize(width: 1280, height: 820),
    selectedDestination: .threads,
    selectedPrompt: "Continue the last planning thread and summarize the open action items.",
    selectedWritingStyle: .strategic,
    highlightedQuickPrompt: .articleSummary
  ) { context, bindings in
    WorkspaceMacView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 1280, height: 820))
}
