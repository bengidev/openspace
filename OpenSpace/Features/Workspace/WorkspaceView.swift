import ComposableArchitecture
import SwiftUI

struct WorkspaceView: View {
  let store: StoreOf<WorkspaceFeature>

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @FocusState private var isPromptFocusedLocal: Bool

  var body: some View {
    GeometryReader { proxy in
      let profile = layoutProfile(for: proxy.size)
      let variant = layoutVariant(for: profile)
        
      ZStack {
        WorkspaceBackdrop(isAnimated: store.hasAppeared && !reduceMotion)

        contentSurface(
          store: store,
          profile: profile,
          variant: variant,
          containerSize: proxy.size
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

  @ViewBuilder
  private func contentSurface(
    store: StoreOf<WorkspaceFeature>,
    profile: WorkspaceLayoutProfile,
    variant: WorkspacePlatformVariant,
    containerSize: CGSize
  ) -> some View {
    let context = WorkspaceRenderContext(
      variant: variant,
      containerSize: containerSize,
      hasAppeared: store.hasAppeared,
      reduceMotion: reduceMotion
    )

    let bindings = WorkspaceViewBindings(
      selectedDestination: Binding(
        get: { store.selectedDestination },
        set: { store.send(.destinationSelected($0)) }
      ),
      selectedModel: Binding(
        get: { store.selectedModel },
        set: { store.send(.modelSelected($0)) }
      ),
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

    let styledShell = shellView(for: variant, context: context, bindings: bindings)
      .frame(maxWidth: profile.shellMaxWidth)
      .padding(.horizontal, profile.shellHorizontalPadding)
      .padding(.vertical, profile.shellVerticalPadding)
      .opacity(store.hasAppeared ? 1 : 0)
      .offset(y: store.hasAppeared ? 0 : 24)
      .scaleEffect(reduceMotion ? 1 : (store.hasAppeared ? 1 : 0.985))
      .animation(.easeOut(duration: 0.85), value: store.hasAppeared)

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
