//
//  OnboardingIOSHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSHeroView: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: context.heroContentSpacing) {
      OnboardingSignalPill(
        isAnimated: context.isAnimated,
        identifierPrefix: "onboarding.ios.hero.signal"
      )

      VStack(spacing: 10) {
        Text("Calm Systems for Fast Builders")
          .font(.system(size: context.heroTitleSize, weight: .medium, design: .default))
          .multilineTextAlignment(.center)
          .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
          .frame(maxWidth: context.heroTextMaxWidth)
          .lineLimit(4)
          .minimumScaleFactor(0.8)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 18)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.ios.hero.title")

        Text("Bring code, prompts, and image generation into one local-first workspace that feels composed even when the work is not.")
          .font(context.heroSubtitleFont)
          .multilineTextAlignment(.center)
          .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
          .frame(maxWidth: context.heroSupportingTextMaxWidth)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 14)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.ios.hero.subtitle")
      }

      OnboardingPrimaryButton(
        title: "Enter OpenSpace",
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        identifier: "onboarding.ios.hero.primary-action",
        action: onContinue
      )
    }
    .accessibilityIdentifier("onboarding.ios.hero")
  }
}

#Preview("iPhone Hero") {
  OnboardingIOSHeroView(
    context: OnboardingPreviewSupport.context(
      variant: .ios,
      size: CGSize(width: 390, height: 844)
    ),
    onContinue: {}
  )
  .padding(28)
  .onboardingPreviewSurface(size: CGSize(width: 390, height: 380))
}
