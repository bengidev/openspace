//
//  WorkspacePreviewSupport.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

#if DEBUG
    enum WorkspacePreviewSupport {
        static func context(
            variant: WorkspacePlatformVariant,
            size: CGSize,
            hasAppeared: Bool = true,
            reduceMotion: Bool = true
        ) -> WorkspaceRenderContext {
            WorkspaceRenderContext(
                variant: variant,
                containerSize: size,
                hasAppeared: hasAppeared,
                reduceMotion: reduceMotion
            )
        }

        static func preview(
            variant: WorkspacePlatformVariant,
            size: CGSize,
            hasAppeared: Bool = true,
            reduceMotion: Bool = true,
            selectedDestination: WorkspaceDestination = .home,
            providers: [AIProvider] = WorkspacePreviewSupport.defaultProviders,
            selectedProviderID: String? = WorkspacePreviewSupport.defaultProviders.first?.id,
            isLoadingProviders: Bool = false,
            providerErrorMessage: String? = nil,
            selectedPrompt: String = "",
            selectedWritingStyle: WorkspaceWritingStyle = .balanced,
            citationEnabled: Bool = true,
            highlightedQuickPrompt: WorkspaceQuickPrompt? = nil,
            @ViewBuilder content: @escaping (WorkspaceRenderContext, WorkspaceViewBindings) -> some View
        ) -> some View {
            WorkspacePreviewHarness(
                context: context(
                    variant: variant,
                    size: size,
                    hasAppeared: hasAppeared,
                    reduceMotion: reduceMotion
                ),
                initialDestination: selectedDestination,
                initialProviders: providers,
                initialProviderID: selectedProviderID,
                initialLoadingProviders: isLoadingProviders,
                initialProviderErrorMessage: providerErrorMessage,
                initialPrompt: selectedPrompt,
                initialWritingStyle: selectedWritingStyle,
                initialCitationEnabled: citationEnabled,
                initialHighlightedQuickPrompt: highlightedQuickPrompt,
                content: content
            )
        }

        static let defaultProviders = [
            AIProvider(
                id: "openai",
                name: "OpenAI",
                npm: "@ai-sdk/openai",
                api: "https://api.openai.com/v1",
                env: ["OPENAI_API_KEY"],
                doc: "https://platform.openai.com/docs"
            ),
            AIProvider(
                id: "anthropic",
                name: "Anthropic",
                npm: "@ai-sdk/anthropic",
                api: "https://api.anthropic.com",
                env: ["ANTHROPIC_API_KEY"],
                doc: "https://docs.anthropic.com"
            ),
        ]
    }

    private struct WorkspacePreviewHarness<Content: View>: View {
        // MARK: Lifecycle

        init(
            context: WorkspaceRenderContext,
            initialDestination: WorkspaceDestination,
            initialProviders: [AIProvider],
            initialProviderID: String?,
            initialLoadingProviders: Bool,
            initialProviderErrorMessage: String?,
            initialPrompt: String,
            initialWritingStyle: WorkspaceWritingStyle,
            initialCitationEnabled: Bool,
            initialHighlightedQuickPrompt: WorkspaceQuickPrompt?,
            @ViewBuilder content: @escaping (WorkspaceRenderContext, WorkspaceViewBindings) -> Content
        ) {
            self.context = context
            self.initialDestination = initialDestination
            self.initialProviders = initialProviders
            self.initialProviderID = initialProviderID
            self.initialLoadingProviders = initialLoadingProviders
            self.initialProviderErrorMessage = initialProviderErrorMessage
            self.initialPrompt = initialPrompt
            self.initialWritingStyle = initialWritingStyle
            self.initialCitationEnabled = initialCitationEnabled
            self.initialHighlightedQuickPrompt = initialHighlightedQuickPrompt
            self.content = content
            _selectedDestination = State(initialValue: initialDestination)
            _selectedProviderID = State(initialValue: initialProviderID)
            _selectedPrompt = State(initialValue: initialPrompt)
            _selectedWritingStyle = State(initialValue: initialWritingStyle)
            _citationEnabled = State(initialValue: initialCitationEnabled)
            _highlightedQuickPrompt = State(initialValue: initialHighlightedQuickPrompt)
        }

        // MARK: Internal

        let context: WorkspaceRenderContext
        let initialDestination: WorkspaceDestination
        let initialProviders: [AIProvider]
        let initialProviderID: String?
        let initialLoadingProviders: Bool
        let initialProviderErrorMessage: String?
        let initialPrompt: String
        let initialWritingStyle: WorkspaceWritingStyle
        let initialCitationEnabled: Bool
        let initialHighlightedQuickPrompt: WorkspaceQuickPrompt?
        let content: (WorkspaceRenderContext, WorkspaceViewBindings) -> Content

        var body: some View {
            content(context, bindings)
        }

        // MARK: Private

        @FocusState private var isPromptFocused: Bool
        @State private var selectedDestination: WorkspaceDestination
        @State private var selectedProviderID: String?
        @State private var selectedPrompt: String
        @State private var selectedWritingStyle: WorkspaceWritingStyle
        @State private var citationEnabled: Bool
        @State private var highlightedQuickPrompt: WorkspaceQuickPrompt?

        private var bindings: WorkspaceViewBindings {
            WorkspaceViewBindings(
                selectedDestination: $selectedDestination,
                providers: initialProviders,
                selectedProviderID: $selectedProviderID,
                isLoadingProviders: initialLoadingProviders,
                providerErrorMessage: initialProviderErrorMessage,
                selectedPrompt: $selectedPrompt,
                selectedWritingStyle: $selectedWritingStyle,
                citationEnabled: $citationEnabled,
                highlightedQuickPrompt: $highlightedQuickPrompt,
                isPromptFocused: $isPromptFocused,
                sendPrompt: { },
                quickPromptTapped: { prompt in
                    highlightedQuickPrompt = prompt
                    selectedPrompt = prompt.rawValue
                    isPromptFocused = true
                },
                replayOnboarding: { }
            )
        }
    }

    extension View {
        func workspacePreviewSurface(size: CGSize) -> some View {
            ZStack {
                WorkspaceBackdrop(isAnimated: false)
                self
            }
            .frame(width: size.width, height: size.height)
            .openSpaceTheme()
        }

        func workspaceComponentPreviewSurface() -> some View {
            padding(28)
                .background(ThemeColor.backgroundPrimary)
                .openSpaceTheme()
                .previewLayout(.sizeThatFits)
        }
    }
#endif
