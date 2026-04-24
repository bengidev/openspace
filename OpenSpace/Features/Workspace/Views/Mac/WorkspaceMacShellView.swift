//
//  WorkspaceMacShellView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceMacShell: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        WorkspaceMacMainContent(context: context, bindings: bindings)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [
                        WorkspacePalette.shellTop(for: colorScheme),
                        WorkspacePalette.shellBottom(for: colorScheme),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(WorkspacePalette.shellStroke(for: colorScheme))
                    .frame(height: 1)
                    .opacity(0.55)
            }
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Mac Workspace Shell") {
    WorkspacePreviewSupport.preview(
        variant: .mac,
        size: CGSize(width: 1280, height: 820),
        selectedDestination: .home
    ) { context, bindings in
        WorkspaceMacShell(context: context, bindings: bindings)
    }
    .workspacePreviewSurface(size: CGSize(width: 1280, height: 820))
}
