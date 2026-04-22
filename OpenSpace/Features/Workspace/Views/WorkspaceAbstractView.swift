//
//  WorkspaceAbstractView.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceAbstractView: View {
  let variant: WorkspacePlatformVariant
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    switch variant {
    case .ios:
      WorkspaceIOSView(context: context, bindings: bindings)
    case .ipad:
      WorkspaceIPadView(context: context, bindings: bindings)
    case .mac:
      WorkspaceMacView(context: context, bindings: bindings)
    }
  }
}
