//
//  WorkspaceIPadHeroHeadingView.swift
//  OpenSpace
//
//  iPad-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIPadHeroHeading

struct WorkspaceIPadHeroHeading: View {
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

#Preview("iPad Workspace Hero Heading") {
    let context = WorkspacePreviewSupport.context(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820)
    )

    WorkspaceIPadHeroHeading(context: context, destination: .threads)
        .frame(width: 760)
        .padding(32)
        .workspacePreviewSurface(size: CGSize(width: 840, height: 240))
}
