//
//  OnboardingIPadHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeroView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: context.heroContentSpacing + 4) {
      OnboardingSignalPill(
        isAnimated: context.isAnimated,
        label: "A larger canvas for coding, image generation, and local AI setup",
        identifierPrefix: "onboarding.ipad.hero.signal"
      )

      VStack(spacing: 12) {
        Text("OpenSpace Expands Without Splitting the Feature")
          .font(.system(size: context.heroTitleSize, weight: .medium, design: .default))
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white)
          .frame(maxWidth: context.heroTextMaxWidth)
          .lineLimit(4)
          .minimumScaleFactor(0.8)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 18)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.ipad.hero.title")

        Text("The iPad variant keeps the same onboarding state and intent, but produces a broader family of components with more room for hierarchy and capability context.")
          .font(context.heroSubtitleFont)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white.opacity(0.88))
          .frame(maxWidth: context.heroSupportingTextMaxWidth)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 14)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.ipad.hero.subtitle")
      }

      OnboardingPrimaryButton(
        title: "Enter OpenSpace",
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        identifier: "onboarding.ipad.hero.primary-action",
        action: onContinue
      )
    }
    .accessibilityIdentifier("onboarding.ipad.hero")
  }
}

#Preview("iPad Hero") {
  OnboardingIPadHeroView(
    context: OnboardingPreviewSupport.context(
      variant: .ipad,
      size: CGSize(width: 834, height: 1194),
      capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
    ),
    onContinue: {}
  )
  .padding(32)
  .onboardingPreviewSurface(size: CGSize(width: 834, height: 430))
}
