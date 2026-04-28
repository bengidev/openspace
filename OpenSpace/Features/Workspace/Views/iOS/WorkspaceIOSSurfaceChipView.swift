//
//  WorkspaceIOSSurfaceChipView.swift
//  OpenSpace
//
//  iPhone-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIOSSurfaceChip

struct WorkspaceIOSSurfaceChip: View {
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

#Preview("iPhone Workspace Surface Chip") {
    let context = WorkspacePreviewSupport.context(
        variant: .ios,
        size: CGSize(width: 390, height: 844)
    )

    WorkspaceIOSSurfaceChip(
        title: "Attach",
        systemImage: "paperclip",
        colorScheme: .dark,
        context: context
    )
    .padding(32)
    .workspacePreviewSurface(size: CGSize(width: 260, height: 160))
}
