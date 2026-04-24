//
//  WorkspaceIPadShellView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIPadShell: View {
    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        WorkspaceRoundedShellContainer(context: context) {
            WorkspaceIPadMainContent(context: context, bindings: bindings)
        }
    }
}

#Preview("iPad Workspace Shell") {
    WorkspacePreviewSupport.preview(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820),
        selectedDestination: .share
    ) { context, bindings in
        WorkspaceIPadShell(context: context, bindings: bindings)
    }
    .workspacePreviewSurface(size: CGSize(width: 1024, height: 820))
}
