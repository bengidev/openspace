//
//  WorkspaceIPadSurfaceChipView.swift
//  OpenSpace
//
//  iPad-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIPadSurfaceChip

struct WorkspaceIPadSurfaceChip: View {
    let title: String
    let systemImage: String
    let colorScheme: ColorScheme
    let context: WorkspaceRenderContext

    var body: some View {
        Button { } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: context.composerControlIconSize, weight: .semibold))

                Text(title)
                    .font(context.composerControlFont)
            }
            .foregroundStyle(WorkspacePalette.primaryText)
            .padding(.horizontal, context.composerControlHorizontalPadding)
            .padding(.vertical, context.composerControlVerticalPadding)
            .background(Capsule().fill(WorkspacePalette.panelSecondary(for: colorScheme)))
            .overlay(
                Capsule()
                    .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Workspace Surface Chip Component") {
    let context = WorkspacePreviewSupport.context(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820)
    )

    WorkspaceIPadSurfaceChip(
        title: "Attach",
        systemImage: "paperclip",
        colorScheme: .dark,
        context: context
    )
    .padding(32)
    .workspaceComponentPreviewSurface()
}
