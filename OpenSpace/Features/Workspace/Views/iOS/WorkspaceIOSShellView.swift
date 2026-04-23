//
//  WorkspaceIOSShellView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIOSShell: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    WorkspaceIOSMainContent(context: context, bindings: bindings)
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
