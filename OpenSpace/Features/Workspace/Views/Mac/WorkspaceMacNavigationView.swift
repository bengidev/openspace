//
//  WorkspaceMacNavigationView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

// MARK: - WorkspaceMacIconRail

struct WorkspaceMacIconRail: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                WorkspaceMacRailBrandButton()

                VStack(spacing: context.railItemSpacing) {
                    ForEach(primaryDestinations, id: \.self) { destination in
                        WorkspaceMacRailButton(
                            title: destination.rawValue,
                            systemImage: destination.systemImage,
                            isSelected: destination == selectedDestination
                        ) {
                            bindings.selectedDestination.wrappedValue = destination
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: context.railItemSpacing) {
                Button(action: bindings.replayOnboarding) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .frame(width: 42, height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(WorkspacePalette.panelSecondary(for: colorScheme))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Replay onboarding")

                ForEach(utilityDestinations, id: \.self) { destination in
                    WorkspaceMacRailButton(
                        title: destination.rawValue,
                        systemImage: destination.systemImage,
                        isSelected: destination == selectedDestination
                    ) {
                        bindings.selectedDestination.wrappedValue = destination
                    }
                }

                Circle()
                    .fill(AppTheme.primaryGradient)
                    .overlay(
                        Text("BT")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.vanillaCream)
                    )
                    .frame(width: 42, height: 42)
                    .padding(.top, 8)
                    .accessibilityLabel("Bambang Tri profile")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 14)
        .accessibilityIdentifier("\(context.variant.identifierPrefix).rail")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var selectedDestination: WorkspaceDestination {
        bindings.selectedDestination.wrappedValue
    }

    private var primaryDestinations: [WorkspaceDestination] {
        WorkspaceDestination.allCases.filter { $0.navigationPlacement == .primary }
    }

    private var utilityDestinations: [WorkspaceDestination] {
        WorkspaceDestination.allCases.filter { $0.navigationPlacement == .utility }
    }
}

// MARK: - WorkspaceMacRailBrandButton

private struct WorkspaceMacRailBrandButton: View {
    // MARK: Internal

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ThemeColor.orbHighlight(for: colorScheme),
                            WorkspacePalette.sidebarSelection(for: colorScheme),
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 24
                    )
                )

            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorkspacePalette.primaryText)
        }
        .frame(width: 36, height: 36)
        .accessibilityLabel("OpenSpace home")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - WorkspaceMacRailButton

private struct WorkspaceMacRailButton: View {
    // MARK: Internal

    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? WorkspacePalette.accentHighlight(for: colorScheme) : WorkspacePalette.secondaryText)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? WorkspacePalette.sidebarSelection(for: colorScheme) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? WorkspacePalette.cardStroke(for: colorScheme) : Color.clear, lineWidth: 1)
                )
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(WorkspacePalette.accentHighlight(for: colorScheme))
                        .frame(width: 3, height: isSelected ? 18 : 0)
                        .opacity(isSelected ? 1 : 0)
                        .offset(x: -8)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Mac Workspace Rail") {
    WorkspacePreviewSupport.preview(
        variant: .mac,
        size: CGSize(width: 1280, height: 820),
        selectedDestination: .files
    ) { context, bindings in
        WorkspaceMacIconRail(context: context, bindings: bindings)
            .frame(width: context.sidebarWidth, height: context.minimumShellHeight)
            .background(WorkspacePalette.sidebarBackground(for: .light))
            .padding(24)
    }
    .workspacePreviewSurface(size: CGSize(width: 220, height: 820))
}
