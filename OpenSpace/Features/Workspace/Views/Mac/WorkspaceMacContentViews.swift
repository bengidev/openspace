//
//  WorkspaceMacContentViews.swift
//  OpenSpace
//
//  macOS-focused workspace main content facade.
//

import SwiftUI

// MARK: - WorkspaceMacMainContent

struct WorkspaceMacMainContent: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    @State private var activeProviderPopup: WorkspaceMacProviderPopup?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            platformContent
                .frame(minHeight: context.minimumShellHeight, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var platformContent: some View {
        #if os(macOS)
            ZStack {
                mainContent

                if let activeProviderPopup {
                    WorkspaceMacCenteredProviderPopupOverlay(dismiss: dismissProviderPopup) {
                        providerPopupContent(for: activeProviderPopup)
                    }
                    .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
            mainContent
                .fullScreenCover(item: $activeProviderPopup) { popup in
                    WorkspaceMacCenteredProviderPopupOverlay(dismiss: dismissProviderPopup) {
                        providerPopupContent(for: popup)
                    }
                    .presentationBackground(.clear)
                }
        #endif
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
            VStack(spacing: context.heroSectionSpacing) {
                WorkspaceMacHeroOrb(context: context)

                WorkspaceMacHeroHeading(context: context, destination: selectedDestination)

                Text(selectedDestination.heroBody)
                    .font(context.heroBodyFont(for: selectedDestination))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: context.heroCopyMaxWidth)

                WorkspaceMacComposerCard(
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
                    activeProviderPopup: $activeProviderPopup,
                    sendPrompt: bindings.sendPrompt
                )
                .frame(maxWidth: context.composerMaxWidth)
                .accessibilityIdentifier("\(context.variant.identifierPrefix).composer")

                WorkspaceMacQuickPromptSection(
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

    @ViewBuilder
    private func providerPopupContent(for popup: WorkspaceMacProviderPopup) -> some View {
        switch popup {
        case .picker:
            WorkspaceMacProviderPickerPopup(
                providers: bindings.providers,
                selectedProviderID: bindings.selectedProviderID.wrappedValue,
                selectProvider: selectProviderForConnection,
                dismiss: dismissProviderPopup
            )

        case let .connection(provider):
            WorkspaceMacProviderConnectionPopup(
                provider: provider,
                dismiss: dismissProviderPopup,
                back: showProviderPickerFromConnection,
                connect: completeProviderConnection
            )
        }
    }

    private func selectProviderForConnection(_ provider: AIProvider) {
        presentProviderPopup(.connection(provider))
    }

    private func completeProviderConnection(_ provider: AIProvider) {
        bindings.selectedProviderID.wrappedValue = provider.id
        dismissProviderPopup()
    }

    private func showProviderPickerFromConnection() {
        presentProviderPopup(.picker)
    }

    private func presentProviderPopup(_ popup: WorkspaceMacProviderPopup) {
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

    private func dismissProviderPopup() {
        #if os(macOS)
            activeProviderPopup = nil
        #else
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                activeProviderPopup = nil
            }
        #endif
    }
}

#Preview("Mac Workspace Content") {
    WorkspacePreviewSupport.preview(
        variant: .mac,
        size: CGSize(width: 1280, height: 820),
        selectedDestination: .home,
        selectedPrompt: "Plan the next three steps for the release candidate.",
        highlightedQuickPrompt: .articleSummary
    ) { context, bindings in
        WorkspaceMacMainContent(context: context, bindings: bindings)
            .frame(width: 1160, height: context.minimumShellHeight, alignment: .topLeading)
            .padding(24)
    }
    .workspacePreviewSurface(size: CGSize(width: 1240, height: 820))
}
