//
//  OnboardingView.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI

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

  private var renderContext: OnboardingRenderContext {
    OnboardingRenderContext(
      capabilityChips: capabilityChips,
      hasAppeared: hasAppeared,
      reduceMotion: reduceMotion
    )
  }

  var body: some View {
    let context = renderContext

    ZStack {
      OnboardingBackdrop(isAnimated: context.isAnimated)

      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 28) {
          Spacer(minLength: 18)

          OnboardingAbstractView(
            variant: platformVariant,
            context: context,
            onContinue: onContinue
          )
        }
        .frame(maxWidth: .infinity)
      }
      .safeAreaPadding(.vertical, 10)
    }
    .task {
      guard !hasAppeared else { return }
      hasAppeared = true
    }
  }
}

#Preview {
  OnboardingView {}
    .openSpaceTheme()
}
