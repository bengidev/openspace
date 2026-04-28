//
//  WorkspaceIPadComposerCardView.swift
//  OpenSpace
//
//  iPad-focused workspace view component.
//

import SwiftUI

// MARK: - WorkspaceIPadComposerCard

struct WorkspaceIPadComposerCard: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let destination: WorkspaceDestination
    let providers: [AIProvider]
    @Binding var selectedProviderID: String?
    let isLoadingProviders: Bool
    let providerErrorMessage: String?
    @Binding var selectedWritingStyle: WorkspaceWritingStyle
    @Binding var citationEnabled: Bool
    @Binding var selectedPrompt: String
    @FocusState.Binding var isPromptFocused: Bool
    @Binding var activeProviderPopup: WorkspaceIPadProviderPopup?

    let sendPrompt: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: context.composerVStackSpacing) {
            ZStack(alignment: .topLeading) {
                if selectedPrompt.isEmpty {
                    Text(destination.composerPlaceholder)
                        .font(context.composerTextFont)
                        .foregroundStyle(WorkspacePalette.tertiaryText(for: colorScheme))
                        .padding(.horizontal, 2)
                        .allowsHitTesting(false)
                }

                TextField("", text: $selectedPrompt, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(context.composerTextFont)
                    .foregroundStyle(WorkspacePalette.primaryText)
                    .focused($isPromptFocused)
                    .lineLimit(context.composerLineLimit)
            }
            .frame(minHeight: context.composerMinHeight, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                isPromptFocused = true
            }

            Divider()
                .overlay(WorkspacePalette.cardStroke(for: colorScheme))

            composerControls
        }
        .padding(context.composerPadding)
        .background(
            RoundedRectangle(cornerRadius: context.composerCornerRadius, style: .continuous)
                .fill(WorkspacePalette.panelBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: context.composerCornerRadius, style: .continuous)
                .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: WorkspacePalette.shadow(for: colorScheme), radius: 18, x: 0, y: 14)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var providerMenu: some View {
        Button {
            presentProviderPopup(.picker)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: providerIconName)
                    .font(.system(size: context.composerControlIconSize, weight: .semibold))

                Text(providerMenuTitle)
                    .lineLimit(1)

                if isLoadingProviders {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
            .font(context.composerControlFont)
            .foregroundStyle(providerMenuForegroundStyle)
            .padding(.horizontal, context.composerControlHorizontalPadding)
            .padding(.vertical, context.composerControlVerticalPadding)
            .background(Capsule().fill(WorkspacePalette.panelSecondary(for: colorScheme)))
            .overlay(
                Capsule()
                    .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isProviderMenuDisabled)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityLabel("AI provider")
        .accessibilityValue(providerMenuTitle)
    }

    private var selectedProvider: AIProvider? {
        guard let selectedProviderID else { return nil }
        return providers.first { $0.id == selectedProviderID }
    }

    private func presentProviderPopup(_ popup: WorkspaceIPadProviderPopup) {
        #if os(macOS)
            activeProviderPopup = popup
        #else
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                activeProviderPopup = popup
            }
        #endif
    }

    private var providerMenuTitle: String {
        if isLoadingProviders {
            return "Loading providers…"
        }

        if providerErrorMessage != nil {
            return "Providers unavailable"
        }

        if providers.isEmpty {
            return "No providers"
        }

        return selectedProvider?.name ?? "Connect provider"
    }

    private var providerIconName: String {
        providerErrorMessage == nil ? "sparkles" : "exclamationmark.triangle"
    }

    private var isProviderMenuDisabled: Bool {
        isLoadingProviders || providerErrorMessage != nil || providers.isEmpty
    }

    private var providerMenuForegroundStyle: Color {
        isProviderMenuDisabled ? WorkspacePalette.secondaryText : WorkspacePalette.primaryText
    }

    @ViewBuilder
    private var composerControls: some View {
        if context.composerUsesCompactFallback {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    WorkspaceIPadSurfaceChip(title: "Attach", systemImage: "paperclip", colorScheme: colorScheme, context: context)
                    providerMenu
                }

                HStack(spacing: 8) {
                    writingStyleMenu
                    Spacer(minLength: 0)
                    citationToggle
                    sendButton
                }
            }
        } else {
            HStack(alignment: .center, spacing: 12) {
                HStack(spacing: 10) {
                    WorkspaceIPadSurfaceChip(title: "Attach", systemImage: "paperclip", colorScheme: colorScheme, context: context)
                    providerMenu
                    writingStyleMenu
                }
                .layoutPriority(1)

                Spacer(minLength: 0)

                citationToggle
                sendButton
            }
        }
    }

    private var writingStyleMenu: some View {
        Menu {
            Picker("Writing style", selection: $selectedWritingStyle) {
                ForEach(WorkspaceWritingStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selectedWritingStyle.rawValue)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
            }
            .font(context.composerControlFont)
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
        .fixedSize(horizontal: true, vertical: false)
    }

    private var citationToggle: some View {
        HStack(spacing: context.citationToggleSpacing) {
            Toggle("", isOn: $citationEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(WorkspacePalette.accentHighlight(for: colorScheme))
                .scaleEffect(context.toggleScale)

            Text("Citation")
                .font(context.citationToggleFont)
                .foregroundStyle(WorkspacePalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .fixedSize(horizontal: true, vertical: false)
        }
        .layoutPriority(context.variant == .ios ? 1 : 0)
    }

    private var sendButton: some View {
        Button(action: sendPrompt) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(WorkspacePalette.primaryButtonForeground(for: colorScheme))
                .frame(width: context.sendButtonSize, height: context.sendButtonSize)
                .background(Circle().fill(WorkspacePalette.primaryButtonBackground(for: colorScheme)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Send prompt")
    }
}

#Preview("iPad Workspace Composer Card") {
    WorkspacePreviewSupport.preview(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820),
        selectedDestination: .threads,
        selectedPrompt: "Continue the design sync thread and extract unresolved decisions."
    ) { context, bindings in
        WorkspaceIPadComposerCard(
            context: context,
            destination: bindings.selectedDestination.wrappedValue,
            providers: bindings.providers,
            selectedProviderID: bindings.selectedProviderID,
            isLoadingProviders: bindings.isLoadingProviders,
            providerErrorMessage: bindings.providerErrorMessage,
            selectedWritingStyle: bindings.selectedWritingStyle,
            citationEnabled: bindings.citationEnabled,
            selectedPrompt: bindings.selectedPrompt,
            isPromptFocused: bindings.isPromptFocused,
            activeProviderPopup: .constant(nil),
            sendPrompt: { }
        )
        .frame(maxWidth: context.composerMaxWidth)
        .padding(24)
    }
    .workspacePreviewSurface(size: CGSize(width: 1024, height: 820))
}
