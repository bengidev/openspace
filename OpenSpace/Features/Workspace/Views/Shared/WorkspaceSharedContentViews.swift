//
//  WorkspaceSharedContentViews.swift
//  OpenSpace
//
//  Shared workspace content views across all platforms.
//  Platform-specific metrics are driven entirely by WorkspaceRenderContext.
//

import SwiftUI

// MARK: - WorkspaceMainContent

struct WorkspaceMainContent: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    var body: some View {
        VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
            VStack(spacing: context.heroSectionSpacing) {
                WorkspaceHeroOrb(context: context)

                WorkspaceHeroHeading(context: context, destination: selectedDestination)

                Text(selectedDestination.heroBody)
                    .font(context.heroBodyFont(for: selectedDestination))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: context.heroCopyMaxWidth)

                WorkspaceComposerCard(
                    context: context,
                    destination: selectedDestination,
                    providers: bindings.providers,
                    selectedProviderID: bindings.selectedProviderID,
                    isLoadingProviders: bindings.isLoadingProviders,
                    providerErrorMessage: bindings.providerErrorMessage,
                    selectedWritingStyle: bindings.selectedWritingStyle,
                    citationEnabled: bindings.citationEnabled,
                    selectedPrompt: bindings.selectedPrompt,
                    isPromptFocused: bindings.isPromptFocused,
                    sendPrompt: bindings.sendPrompt
                )
                .frame(maxWidth: context.composerMaxWidth)
                .accessibilityIdentifier("\(context.variant.identifierPrefix).composer")

                WorkspaceQuickPromptSection(
                    context: context,
                    highlightedQuickPrompt: bindings.highlightedQuickPrompt,
                    selectedPrompt: bindings.selectedPrompt,
                    isPromptFocused: bindings.isPromptFocused,
                    quickPromptTapped: bindings.quickPromptTapped
                )
                .frame(maxWidth: context.quickPromptMaxWidth)
                .accessibilityIdentifier("\(context.variant.identifierPrefix).examples")
            }
            .frame(maxWidth: .infinity)
            .padding(.top, context.heroTopSpacing)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, context.mainHorizontalPadding)
        .padding(.vertical, context.mainVerticalPadding)
    }

    // MARK: Private

    private var selectedDestination: WorkspaceDestination {
        bindings.selectedDestination.wrappedValue
    }
}

// MARK: - WorkspaceHeroOrb

private struct WorkspaceHeroOrb: View {
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

// MARK: - WorkspaceHeroHeading

private struct WorkspaceHeroHeading: View {
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

// MARK: - WorkspaceComposerCard

private struct WorkspaceComposerCard: View {
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
    @State private var activeProviderPopup: WorkspaceProviderPopup?

    private enum WorkspaceProviderPopup: Identifiable {
        case picker
        case connection(AIProvider)

        var id: String {
            switch self {
            case .picker:
                "picker"
            case let .connection(provider):
                "connection-\(provider.id)"
            }
        }
    }

    private var providerMenu: some View {
        Button {
            activeProviderPopup = .picker
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
        .popover(item: $activeProviderPopup, arrowEdge: .bottom) { popup in
            switch popup {
            case .picker:
                WorkspaceProviderPickerPopup(
                    providers: providers,
                    selectedProviderID: selectedProviderID,
                    selectProvider: selectProviderForConnection,
                    dismiss: { activeProviderPopup = nil }
                )
                .presentationCompactAdaptation(.popover)

            case let .connection(provider):
                WorkspaceProviderConnectionPopup(
                    provider: provider,
                    dismiss: { activeProviderPopup = nil },
                    back: showProviderPickerFromConnection,
                    connect: completeProviderConnection
                )
                .presentationCompactAdaptation(.popover)
            }
        }
    }

    private var selectedProvider: AIProvider? {
        guard let selectedProviderID else { return nil }
        return providers.first { $0.id == selectedProviderID }
    }

    private func selectProviderForConnection(_ provider: AIProvider) {
        activeProviderPopup = .connection(provider)
    }

    private func completeProviderConnection(_ provider: AIProvider) {
        selectedProviderID = provider.id
        activeProviderPopup = nil
    }

    private func showProviderPickerFromConnection() {
        activeProviderPopup = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            activeProviderPopup = .picker
        }
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
                    WorkspaceSurfaceChip(title: "Attach", systemImage: "paperclip", colorScheme: colorScheme, context: context)
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
                    WorkspaceSurfaceChip(title: "Attach", systemImage: "paperclip", colorScheme: colorScheme, context: context)
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

// MARK: - WorkspaceSurfaceChip

private struct WorkspaceSurfaceChip: View {
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

// MARK: - WorkspaceQuickPromptSection

private struct WorkspaceQuickPromptSection: View {
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

// MARK: - WorkspaceCompactNavigation

private struct WorkspaceCompactNavigation: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let selectedDestination: Binding<WorkspaceDestination>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: context.compactNavItemSpacing) {
                ForEach(destinations, id: \.self) { destination in
                    Button {
                        selectedDestination.wrappedValue = destination
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: destination.systemImage)
                                .font(.system(size: 12, weight: .medium))
                            Text(destination.displayName)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(
                            destination == selectedDestination.wrappedValue
                                ? WorkspacePalette.primaryText
                                : WorkspacePalette.secondaryText
                        )
                        .padding(.horizontal, context.compactNavHorizontalPadding)
                        .padding(.vertical, context.compactNavVerticalPadding)
                        .background(
                            Capsule().fill(
                                destination == selectedDestination.wrappedValue
                                    ? WorkspacePalette.sidebarSelection(for: colorScheme)
                                    : WorkspacePalette.panelSecondary(for: colorScheme)
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, context.compactNavBottomPadding)
        }
        .scrollClipDisabled()
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var destinations: [WorkspaceDestination] {
        WorkspaceDestination.allCases.filter { $0.navigationPlacement == .primary }
    }
}
