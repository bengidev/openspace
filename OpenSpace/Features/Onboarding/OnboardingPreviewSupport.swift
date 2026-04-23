//
//  OnboardingPreviewSupport.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

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
