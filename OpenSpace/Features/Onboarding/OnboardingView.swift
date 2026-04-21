//
//  OnboardingView.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct OnboardingView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var hasAppeared = false

  let onContinue: () -> Void

  private let capabilityChips = [
    "Code",
    "Images",
    "Research",
    "Automation",
  ]

  private var platformVariant: OnboardingPlatformVariant {
    #if os(macOS)
      return .mac
    #elseif os(iOS)
      return UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
    #else
      return .ios
    #endif
  }

  private func renderContext(
    for size: CGSize,
    variant: OnboardingPlatformVariant
  ) -> OnboardingRenderContext {
    OnboardingRenderContext(
      variant: variant,
      capabilityChips: capabilityChips,
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
        OnboardingBackdrop(isAnimated: context.isAnimated)

        switch variant {
        case .mac:
          VStack(spacing: 0) {
            OnboardingAbstractView(
              variant: variant,
              context: context,
              onContinue: onContinue
            )

            Spacer(minLength: 0)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .ios, .ipad:
          ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
              Spacer(minLength: 18)

              OnboardingAbstractView(
                variant: variant,
                context: context,
                onContinue: onContinue
              )
            }
            .frame(
              maxWidth: .infinity,
              minHeight: max(proxy.size.height - 20, 0),
              alignment: .top
            )
          }
          .safeAreaPadding(.vertical, 10)
        }
      }
    }
    .task {
      guard !hasAppeared else { return }
      hasAppeared = true
      #if os(macOS)
        configureMacWindow()
      #endif
    }
  }

  #if os(macOS)
    private func configureMacWindow() {
      DispatchQueue.main.async {
        guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else { return }
        let minimumSize = NSSize(width: 980, height: 620)
        window.minSize = minimumSize
        window.setContentSize(NSSize(width: 1120, height: 620))
      }
    }
  #endif
}

#Preview {
  OnboardingView {}
    .openSpaceTheme()
}
