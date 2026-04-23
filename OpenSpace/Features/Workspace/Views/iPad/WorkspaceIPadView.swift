//
//  WorkspaceIPadView.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceIPadView: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceIPadShell(context: context, bindings: bindings)
    .accessibilityIdentifier("workspace.ipad.content")
  }
}

#Preview("Workspace iPad Content") {
  WorkspacePreviewSupport.preview(
    variant: .ipad,
    size: CGSize(width: 834, height: 1194),
    highlightedQuickPrompt: .emailReply
  ) { context, bindings in
    WorkspaceIPadView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 834, height: 1194))
}

#Preview("Workspace iPad Compact") {
  WorkspacePreviewSupport.preview(
    variant: .ipad,
    size: CGSize(width: 744, height: 1133),
    selectedDestination: .files,
    selectedPrompt: "Pull the latest project brief into the workspace and outline the next deliverables."
  ) { context, bindings in
    WorkspaceIPadView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 744, height: 1133))
}
