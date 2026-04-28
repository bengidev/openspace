import ComposableArchitecture
import SwiftUI

struct WorkspaceView: View {
    // MARK: Internal

    let store: StoreOf<WorkspaceFeature>

    var body: some View {
        GeometryReader { proxy in
            let context = WorkspaceRenderContext.currentPlatform(
                containerSize: proxy.size,
                hasAppeared: store.hasAppeared,
                reduceMotion: reduceMotion
            )

            ZStack {
                WorkspaceBackdrop(isAnimated: context.isAnimated)

                contentSurface(
                    store: store,
                    context: context
                )
            }
            .onAppear {
                isPromptFocusedLocal = store.isPromptFocused
            }
            .onChange(of: store.isPromptFocused) { _, newValue in
                isPromptFocusedLocal = newValue
            }
            .onChange(of: isPromptFocusedLocal) { _, newValue in
                store.send(.promptFocused(newValue))
            }
            .task {
                guard !store.hasAppeared else { return }
                store.send(.appeared)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isPromptFocusedLocal: Bool

    @ViewBuilder
    private func contentSurface(
        store: StoreOf<WorkspaceFeature>,
        context: WorkspaceRenderContext
    ) -> some View {
        let bindings = WorkspaceViewBindings(
            selectedDestination: Binding(
                get: { store.selectedDestination },
                set: { store.send(.destinationSelected($0)) }
            ),
            providers: store.providers,
            selectedProviderID: Binding(
                get: { store.selectedProviderID },
                set: { store.send(.providerSelected($0)) }
            ),
            isLoadingProviders: store.isLoadingProviders,
            providerErrorMessage: store.providerErrorMessage,
            selectedPrompt: Binding(
                get: { store.selectedPrompt },
                set: { store.send(.promptChanged($0)) }
            ),
            selectedWritingStyle: Binding(
                get: { store.selectedWritingStyle },
                set: { store.send(.writingStyleSelected($0)) }
            ),
            citationEnabled: Binding(
                get: { store.citationEnabled },
                set: { store.send(.citationToggled($0)) }
            ),
            highlightedQuickPrompt: Binding(
                get: { store.highlightedQuickPrompt },
                set: { _ in }
            ),
            isPromptFocused: $isPromptFocusedLocal,
            sendPrompt: { store.send(.sendButtonTapped) },
            quickPromptTapped: { prompt in store.send(.quickPromptTapped(prompt)) },
            replayOnboarding: { store.send(.replayOnboarding) }
        )

        let styledShell = WorkspacePlatformViewFactory.makeShell(for: context.variant, context: context, bindings: bindings)
            .frame(width: context.shellWidth)
            .padding(.horizontal, context.shellHorizontalPadding)
            .padding(.vertical, context.shellVerticalPadding)
            .opacity(context.hasAppeared ? 1 : 0)
            .offset(y: context.hasAppeared ? 0 : 24)
            .scaleEffect(context.reduceMotion ? 1 : (context.hasAppeared ? 1 : 0.985))
            .animation(.easeOut(duration: 0.85), value: context.hasAppeared)

        #if os(macOS)
            styledShell
        #else
            ScrollView(.vertical, showsIndicators: false) {
                styledShell
            }
        #endif
    }
}
