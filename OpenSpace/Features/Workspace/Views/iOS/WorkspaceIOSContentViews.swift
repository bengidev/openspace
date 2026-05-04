//
//  WorkspaceIOSContentViews.swift
//  OpenSpace
//
//  iPhone-focused workspace main content facade.
//

import SwiftUI

// MARK: - WorkspaceIOSMainContent

struct WorkspaceIOSMainContent: View {
    // MARK: Internal

    let context: WorkspaceRenderContext
    let bindings: WorkspaceViewBindings

    @State private var activeProviderPopup: WorkspaceIOSProviderPopup?

    var body: some View {
        mainContent
            .fullScreenCover(item: $activeProviderPopup) { popup in
                WorkspaceIOSCenteredProviderPopupOverlay(dismiss: dismissProviderPopup) {
                    providerPopupContent(for: popup)
                }
                .presentationBackground(.clear)
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
            VStack(spacing: context.heroSectionSpacing) {
                WorkspaceIOSHeroOrb(context: context)

                WorkspaceIOSHeroHeading(context: context, destination: selectedDestination)

                Text(selectedDestination.heroBody)
                    .font(context.heroBodyFont(for: selectedDestination))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: context.heroCopyMaxWidth)

                WorkspaceIOSComposerCard(
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

                WorkspaceIOSQuickPromptSection(
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
    private func providerPopupContent(for popup: WorkspaceIOSProviderPopup) -> some View {
        switch popup {
        case .picker:
            WorkspaceIOSProviderPickerPopup(
                providers: bindings.providers,
                selectedProviderID: bindings.selectedProviderID.wrappedValue,
                selectProvider: selectProviderForConnection,
                dismiss: dismissProviderPopup
            )

        case let .connection(provider):
            WorkspaceIOSProviderConnectionPopup(
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

    private func presentProviderPopup(_ popup: WorkspaceIOSProviderPopup) {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            activeProviderPopup = popup
        }
    }

    private func dismissProviderPopup() {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            activeProviderPopup = nil
        }
    }
}
