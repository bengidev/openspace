//
//  WorkspaceRoundedShellContainer.swift
//  OpenSpace
//
//  Shared rounded shell chrome for touch platforms.
//

import SwiftUI

struct WorkspaceRoundedShellContainer<Content: View>: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    @ViewBuilder let content: Content

    var body: some View {
        let shellShape = RoundedRectangle(cornerRadius: context.shellCornerRadius, style: .continuous)

        content
            .frame(maxWidth: .infinity, minHeight: context.minimumShellHeight, maxHeight: .infinity, alignment: .topLeading)
            .background(
                shellShape
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
            .compositingGroup()
            .clipShape(shellShape)
            .overlay(
                shellShape
                    .strokeBorder(WorkspacePalette.shellStroke(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: WorkspacePalette.shadow(for: colorScheme), radius: 32, x: 0, y: 18)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}
