//
//  WorkspaceIOSShellView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIOSShell: View {
    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        WorkspaceRoundedShellContainer(context: context) {
            WorkspaceIOSMainContent(context: context, bindings: bindings)
        }
    }
}

#Preview("iPhone Workspace Shell") {
    WorkspacePreviewSupport.preview(
        variant: .ios,
        size: CGSize(width: 390, height: 844),
        selectedDestination: .home
    ) { context, bindings in
        WorkspaceIOSShell(context: context, bindings: bindings)
    }
    .workspacePreviewSurface(size: CGSize(width: 390, height: 844))
}
