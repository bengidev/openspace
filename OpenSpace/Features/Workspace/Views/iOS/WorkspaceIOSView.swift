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
    WorkspaceCompactShell(context: context, bindings: bindings)
      .accessibilityIdentifier("workspace.ios.content")
  }
}
