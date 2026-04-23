//
//  WorkspaceIOSView.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceIOSView: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceIOSShell(context: context, bindings: bindings)
      .accessibilityIdentifier("workspace.ios.content")
  }
}

#Preview("Workspace iPhone Content") {
  WorkspacePreviewSupport.preview(
    variant: .ios,
    size: CGSize(width: 390, height: 844)
  ) { context, bindings in
    WorkspaceIOSView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 390, height: 844))
}

#Preview("Workspace iPhone Prompt") {
  WorkspacePreviewSupport.preview(
    variant: .ios,
    size: CGSize(width: 390, height: 844),
    selectedDestination: .share,
    selectedPrompt: "Draft an invite note for the design review thread.",
    selectedWritingStyle: .concise
  ) { context, bindings in
    WorkspaceIOSView(context: context, bindings: bindings)
  }
  .workspacePreviewSurface(size: CGSize(width: 390, height: 844))
}
