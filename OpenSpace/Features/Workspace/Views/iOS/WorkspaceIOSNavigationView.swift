//
//  WorkspaceIOSNavigationView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIOSCompactNavigation: View {
    // MARK: Internal

    @Binding var selectedDestination: WorkspaceDestination

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(destinations, id: \.self) { destination in
                    Button {
                        selectedDestination = destination
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: destination.systemImage)
                                .font(.system(size: 12, weight: .medium))

                            Text(destination.rawValue)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(
                            destination == selectedDestination
                                ? WorkspacePalette.primaryText
                                : WorkspacePalette.secondaryText
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    destination == selectedDestination
                                        ? WorkspacePalette.sidebarSelection(for: colorScheme)
                                        : WorkspacePalette.panelSecondary(for: colorScheme)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 2)
        }
        .scrollClipDisabled()
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var destinations: [WorkspaceDestination] {
        WorkspaceDestination.allCases.filter { $0.navigationPlacement == .primary }
    }
}

#Preview("iPhone Compact Navigation") {
    WorkspacePreviewSupport.preview(
        variant: .ios,
        size: CGSize(width: 390, height: 844),
        selectedDestination: .files
    ) { _, bindings in
        WorkspaceIOSCompactNavigation(selectedDestination: bindings.selectedDestination)
            .padding(20)
    }
    .workspaceComponentPreviewSurface()
}
