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
    WorkspaceRegularShell(context: context, bindings: bindings)
      .frame(maxWidth: .infinity, minHeight: context.preferredShellHeight, alignment: .center)
      .accessibilityIdentifier("workspace.mac.content")
  }
}
