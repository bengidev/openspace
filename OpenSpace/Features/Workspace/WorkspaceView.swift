//
//  WorkspaceView.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct WorkspaceView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @FocusState private var isPromptFocused: Bool

  @State private var selectedDestination: WorkspaceDestination = .textToImage
  @State private var selectedModel: WorkspaceModel = .artboard3
  @State private var selectedPrompt = ""
  @State private var selectedStyleChips = Set<WorkspaceStyleChip>([
    .highQuality,
    .fourK,
    .cinematic,
  ])
  @State private var toneValue = 0.24
  @State private var isRandomized = false
  @State private var highlightedQuickPrompt: WorkspaceQuickPrompt?
  @State private var hasAppeared = false
  #if os(macOS)
  @State private var hasConfiguredWindow = false
  #endif

  let replayOnboarding: () -> Void

  private var platformVariant: WorkspacePlatformVariant {
    #if os(macOS)
      return .mac
    #elseif os(iOS)
      return UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
    #else
      return .ios
    #endif
  }

  private var bindings: WorkspaceViewBindings {
    WorkspaceViewBindings(
      selectedDestination: $selectedDestination,
      selectedModel: $selectedModel,
      selectedPrompt: $selectedPrompt,
      selectedStyleChips: $selectedStyleChips,
      toneValue: $toneValue,
      isRandomized: $isRandomized,
      highlightedQuickPrompt: $highlightedQuickPrompt,
      isPromptFocused: $isPromptFocused,
      replayOnboarding: replayOnboarding
    )
  }

  private func renderContext(
    for size: CGSize,
    variant: WorkspacePlatformVariant
  ) -> WorkspaceRenderContext {
    WorkspaceRenderContext(
      variant: variant,
      containerSize: size,
      hasAppeared: hasAppeared,
      reduceMotion: reduceMotion
    )
  }

  var body: some View {
    let variant = platformVariant

    GeometryReader { proxy in
      let context = renderContext(for: proxy.size, variant: variant)

      ZStack {
        WorkspaceBackdrop(isAnimated: context.isAnimated)

        contentSurface(context: context, variant: variant)
      }
      .task {
        guard !hasAppeared else { return }
        hasAppeared = true
        #if os(macOS)
          configureMacWindow(context: context)
        #endif
      }
    }
  }

  @ViewBuilder
  private func contentSurface(
    context: WorkspaceRenderContext,
    variant: WorkspacePlatformVariant
  ) -> some View {
    let content = WorkspaceAbstractView(
      variant: variant,
      context: context,
      bindings: bindings
    )
    .frame(maxWidth: context.shellMaxWidth)
    .padding(.horizontal, context.shellHorizontalPadding)
    .padding(.vertical, context.shellVerticalPadding)
    .opacity(hasAppeared ? 1 : 0)
    .offset(y: hasAppeared ? 0 : 24)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.85), value: hasAppeared)

    #if os(macOS)
      if variant == .mac {
        content
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      } else {
        ScrollView(.vertical, showsIndicators: false) {
          content
        }
      }
    #else
      ScrollView(.vertical, showsIndicators: false) {
        content
      }
    #endif
  }

  #if os(macOS)
    private func configureMacWindow(context: WorkspaceRenderContext) {
      guard !hasConfiguredWindow else { return }

      DispatchQueue.main.async {
        guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else { return }

        let minimumSize = NSSize(
          width: context.minimumWindowSize.width,
          height: context.minimumWindowSize.height
        )
        let idealSize = NSSize(
          width: context.idealWindowSize.width,
          height: context.idealWindowSize.height
        )

        window.minSize = minimumSize
        window.setContentSize(idealSize)
        hasConfiguredWindow = true
      }
    }
  #endif
}

#Preview("Workspace Desktop") {
  WorkspaceView {}
    .frame(width: 1280, height: 820)
    .openSpaceTheme()
}

#Preview("Workspace Compact") {
  WorkspaceView {}
    .frame(width: 390, height: 844)
    .openSpaceTheme()
}
