//
//  WorkspaceIPadQuickPromptSectionView.swift
//  OpenSpace
//
//  iPad-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIPadQuickPromptSection

struct WorkspaceIPadQuickPromptSection: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    @Binding var highlightedQuickPrompt: WorkspaceQuickPrompt?
    @Binding var selectedPrompt: String
    @FocusState.Binding var isPromptFocused: Bool

    let quickPromptTapped: (WorkspaceQuickPrompt) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GET STARTED WITH AN EXAMPLE BELOW")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(WorkspacePalette.secondaryText)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(WorkspaceQuickPrompt.allCases) { prompt in
                    Button {
                        quickPromptTapped(prompt)
                    } label: {
                        VStack(alignment: .leading, spacing: 18) {
                            Text(prompt.rawValue)
                                .font(.headline.weight(.medium))
                                .foregroundStyle(WorkspacePalette.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer(minLength: 0)

                            Image(systemName: prompt.symbolName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(
                                    highlightedQuickPrompt == prompt
                                        ? WorkspacePalette.accentHighlight(for: colorScheme)
                                        : WorkspacePalette.primaryText
                                )
                        }
                        .padding(context.quickPromptPadding)
                        .frame(minHeight: context.quickPromptMinHeight, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    highlightedQuickPrompt == prompt
                                        ? WorkspacePalette.sidebarSelection(for: colorScheme)
                                        : WorkspacePalette.panelSecondary(for: colorScheme)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(
                                    highlightedQuickPrompt == prompt
                                        ? WorkspacePalette.accentHighlightMuted(for: colorScheme)
                                        : WorkspacePalette.cardStroke(for: colorScheme),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: context.quickPromptGridMinWidth), spacing: 14)]
    }
}

#Preview("Workspace Quick Prompts Component") {
    WorkspacePreviewSupport.preview(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820),
        highlightedQuickPrompt: .articleSummary
    ) { context, bindings in
        WorkspaceIPadQuickPromptSection(
            context: context,
            highlightedQuickPrompt: bindings.highlightedQuickPrompt,
            selectedPrompt: bindings.selectedPrompt,
            isPromptFocused: bindings.isPromptFocused,
            quickPromptTapped: bindings.quickPromptTapped
        )
        .frame(width: context.quickPromptMaxWidth)
        .padding(24)
    }
    .workspaceComponentPreviewSurface()
}
