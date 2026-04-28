//
//  WorkspaceIOSHeroHeadingView.swift
//  OpenSpace
//
//  iPhone-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIOSHeroHeading

struct WorkspaceIOSHeroHeading: View {
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

#Preview("iPhone Workspace Hero Heading") {
    let context = WorkspacePreviewSupport.context(
        variant: .ios,
        size: CGSize(width: 390, height: 844)
    )

    WorkspaceIOSHeroHeading(context: context, destination: .home)
        .frame(width: 360)
        .padding(32)
        .workspacePreviewSurface(size: CGSize(width: 390, height: 240))
}
