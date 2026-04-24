//
//  WorkspaceIPadShellView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIPadShell: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceIPadMainContent(context: context, bindings: bindings)
      .frame(maxWidth: .infinity, minHeight: context.minimumShellHeight, maxHeight: .infinity, alignment: .topLeading)
      .background(WorkspacePalette.sidebarBackground(for: colorScheme))
      .background(
        RoundedRectangle(cornerRadius: context.shellCornerRadius, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                WorkspacePalette.shellTop(for: colorScheme),
                WorkspacePalette.shellBottom(for: colorScheme),
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: context.shellCornerRadius, style: .continuous)
          .stroke(WorkspacePalette.shellStroke(for: colorScheme), lineWidth: 1)
      )
      .shadow(color: WorkspacePalette.shadow(for: colorScheme), radius: 32, x: 0, y: 18)
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
