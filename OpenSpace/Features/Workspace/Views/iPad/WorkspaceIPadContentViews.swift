//
//  WorkspaceIPadContentViews.swift
//  OpenSpace
//
//  iPad-specific thin wrappers around shared content views.
//  All layout logic lives in WorkspaceRenderContext and WorkspaceSharedContentViews.
//

import SwiftUI

struct WorkspaceIPadMainContent: View {
    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        WorkspaceMainContent(context: context, bindings: bindings)
    }
}

#Preview("iPad Workspace Content") {
    WorkspacePreviewSupport.preview(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820),
        selectedDestination: .threads,
        selectedPrompt: "Continue the design sync thread and extract unresolved decisions.",
        selectedWritingStyle: .strategic,
        highlightedQuickPrompt: .emailReply
    ) { context, bindings in
        WorkspaceIPadMainContent(context: context, bindings: bindings)
            .frame(width: 920, height: context.minimumShellHeight, alignment: .topLeading)
            .padding(24)
    }
    .workspacePreviewSurface(size: CGSize(width: 1024, height: 820))
}
