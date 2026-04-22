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
    Group {
      if context.usesSidebar {
        WorkspaceRegularShell(context: context, bindings: bindings)
      } else {
        WorkspaceCompactShell(context: context, bindings: bindings)
      }
    }
    .accessibilityIdentifier("workspace.ipad.content")
  }
}
