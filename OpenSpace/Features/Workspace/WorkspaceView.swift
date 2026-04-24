import ComposableArchitecture
import SwiftUI

struct WorkspaceView: View {
  let store: StoreOf<WorkspaceFeature>

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @FocusState private var isPromptFocusedLocal: Bool

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      GeometryReader { proxy in
        let profile = layoutProfile(for: proxy.size)
        let variant = layoutVariant(for: profile)

        ZStack {
          WorkspaceBackdrop(isAnimated: viewStore.hasAppeared && !reduceMotion)

          contentSurface(
            viewStore: viewStore,
            profile: profile,
            variant: variant,
            containerSize: proxy.size
          )
        }
        .onAppear {
          isPromptFocusedLocal = viewStore.isPromptFocused
        }
        .onChange(of: viewStore.isPromptFocused) { _, newValue in
          isPromptFocusedLocal = newValue
        }
        .onChange(of: isPromptFocusedLocal) { _, newValue in
          viewStore.send(.promptFocused(newValue))
        }
        .task {
          guard !viewStore.hasAppeared else { return }
          viewStore.send(.appeared)
        }
      }
    }
  }

  @ViewBuilder
  private func contentSurface(
    viewStore: ViewStoreOf<WorkspaceFeature>,
    profile: WorkspaceLayoutProfile,
    variant: WorkspacePlatformVariant,
    containerSize: CGSize
  ) -> some View {
    let context = WorkspaceRenderContext(
      variant: variant,
      containerSize: containerSize,
      hasAppeared: viewStore.hasAppeared,
      reduceMotion: reduceMotion
    )

    let bindings = WorkspaceViewBindings(
      selectedDestination: Binding(
        get: { viewStore.selectedDestination },
        set: { viewStore.send(.destinationSelected($0)) }
      ),
      selectedModel: Binding(
        get: { viewStore.selectedModel },
        set: { viewStore.send(.modelSelected($0)) }
      ),
      selectedPrompt: Binding(
        get: { viewStore.selectedPrompt },
        set: { viewStore.send(.promptChanged($0)) }
      ),
      selectedWritingStyle: Binding(
        get: { viewStore.selectedWritingStyle },
        set: { viewStore.send(.writingStyleSelected($0)) }
      ),
      citationEnabled: Binding(
        get: { viewStore.citationEnabled },
        set: { viewStore.send(.citationToggled($0)) }
      ),
      highlightedQuickPrompt: Binding(
        get: { viewStore.highlightedQuickPrompt },
        set: { _ in }
      ),
      isPromptFocused: $isPromptFocusedLocal,
      sendPrompt: { viewStore.send(.sendButtonTapped) },
      quickPromptTapped: { prompt in viewStore.send(.quickPromptTapped(prompt)) },
      replayOnboarding: { viewStore.send(.replayOnboarding) }
    )

    let styledShell = shellView(for: variant, context: context, bindings: bindings)
      .frame(maxWidth: profile.shellMaxWidth)
      .padding(.horizontal, profile.shellHorizontalPadding)
      .padding(.vertical, profile.shellVerticalPadding)
      .opacity(viewStore.hasAppeared ? 1 : 0)
      .offset(y: viewStore.hasAppeared ? 0 : 24)
      .scaleEffect(reduceMotion ? 1 : (viewStore.hasAppeared ? 1 : 0.985))
      .animation(.easeOut(duration: 0.85), value: viewStore.hasAppeared)

    #if os(macOS)
    styledShell
    #else
    ScrollView(.vertical, showsIndicators: false) {
      styledShell
    }
    #endif
  }

  @ViewBuilder
  private func shellView(
    for variant: WorkspacePlatformVariant,
    context: WorkspaceRenderContext,
    bindings: WorkspaceViewBindings
  ) -> some View {
    switch variant {
    case .ios:
      WorkspaceIOSShell(context: context, bindings: bindings)
    case .ipad:
      WorkspaceIPadShell(context: context, bindings: bindings)
    case .mac:
      WorkspaceMacShell(context: context, bindings: bindings)
    }
  }

  private func layoutProfile(for size: CGSize) -> WorkspaceLayoutProfile {
    #if os(macOS)
      MacLayoutProfile(containerSize: size)
    #elseif os(iOS)
      if UIDevice.current.userInterfaceIdiom == .pad {
        IPadLayoutProfile(containerSize: size)
      } else {
        IOSLayoutProfile(containerSize: size)
      }
    #else
      IOSLayoutProfile(containerSize: size)
    #endif
  }

  private func layoutVariant(for profile: WorkspaceLayoutProfile) -> WorkspacePlatformVariant {
    #if os(macOS)
      return .mac
    #elseif os(iOS)
      if profile is IPadLayoutProfile {
        return .ipad
      }
      return .ios
    #else
      return .ios
    #endif
  }

}
