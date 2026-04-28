//
//  WorkspaceMacHeroOrbView.swift
//  OpenSpace
//
//  macOS-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceMacHeroOrb

struct WorkspaceMacHeroOrb: View {
    // MARK: Internal

    let context: WorkspaceRenderContext

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        ThemeColor.orbHighlight(for: colorScheme),
                        WorkspacePalette.orbCore(for: colorScheme),
                        WorkspacePalette.orbEdge(for: colorScheme),
                    ],
                    center: .topLeading,
                    startRadius: 2,
                    endRadius: 42
                )
            )
            .overlay(Circle().stroke(ThemeColor.accent100.opacity(0.42), lineWidth: 1))
            .frame(width: context.heroOrbSize, height: context.heroOrbSize)
            .shadow(color: WorkspacePalette.orbEdge(for: colorScheme).opacity(0.24), radius: 18, x: 0, y: 12)
            .shadow(color: WorkspacePalette.orbCore(for: colorScheme).opacity(0.16), radius: 28, x: 0, y: 0)
            .overlay(Circle().stroke(ThemeColor.accent100.opacity(0.34), lineWidth: 1))
            .accessibilityHidden(true)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Mac Workspace Hero Orb") {
    let context = WorkspacePreviewSupport.context(
        variant: .mac,
        size: CGSize(width: 1280, height: 820)
    )

    WorkspaceMacHeroOrb(context: context)
        .padding(48)
        .workspacePreviewSurface(size: CGSize(width: 240, height: 240))
}
