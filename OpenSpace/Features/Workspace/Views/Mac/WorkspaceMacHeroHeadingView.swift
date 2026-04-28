//
//  WorkspaceMacHeroHeadingView.swift
//  OpenSpace
//
//  macOS-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceMacHeroHeading

struct WorkspaceMacHeroHeading: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let destination: WorkspaceDestination

    var body: some View {
        VStack(spacing: context.heroHeadingSpacing) {
            Text(destination.heroFirstLine)
                .font(context.heroTitleFont)
                .foregroundStyle(WorkspacePalette.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(context.heroTitleMinimumScaleFactor)

            HStack(spacing: 0) {
                if !destination.heroSecondLineLeading.isEmpty {
                    Text(destination.heroSecondLineLeading)
                        .foregroundStyle(WorkspacePalette.primaryText)
                }

                Text(destination.heroAccentText)
                    .foregroundStyle(WorkspacePalette.heroAccentGradient(for: colorScheme))
            }
            .font(context.heroTitleFont)
            .frame(maxWidth: context.heroHeadingMaxWidth ?? .infinity, alignment: .center)
            .lineLimit(1)
            .minimumScaleFactor(context.heroTitleMinimumScaleFactor)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Workspace Hero Heading Component") {
    let context = WorkspacePreviewSupport.context(
        variant: .mac,
        size: CGSize(width: 1280, height: 820)
    )

    WorkspaceMacHeroHeading(context: context, destination: .home)
        .frame(width: 920)
        .padding(32)
        .workspaceComponentPreviewSurface()
}
