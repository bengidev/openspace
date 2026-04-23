//
//  OnboardingRenderContext.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingRenderContext {
  let capabilityChips: [String]
  let containerSize: CGSize
  let hasAppeared: Bool
  let reduceMotion: Bool

  var isAnimated: Bool {
    !reduceMotion && hasAppeared
  }
}

#if DEBUG
enum OnboardingPreviewSupport {
  static let defaultCapabilityChips = [
    "Code",
    "Images",
    "Research",
    "Automation",
  ]

  static func context(
    variant _: OnboardingPlatformVariant,
    size: CGSize,
    hasAppeared: Bool = true,
    reduceMotion: Bool = true,
    capabilityChips: [String] = defaultCapabilityChips
  ) -> OnboardingRenderContext {
    OnboardingRenderContext(
      capabilityChips: capabilityChips,
      containerSize: size,
      hasAppeared: hasAppeared,
      reduceMotion: reduceMotion
    )
  }
}

extension View {
  func onboardingPreviewSurface(size: CGSize) -> some View {
    ZStack {
      OnboardingBackdrop(isAnimated: false)
      self
    }
    .frame(width: size.width, height: size.height)
    .openSpaceTheme()
  }
}
#endif
