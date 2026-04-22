//
//  OnboardingIOSView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      OnboardingPlatformPanel(variant: .ios, context: context) {
        VStack(spacing: 0) {
          OnboardingIOSHeaderView()
            .accessibilityIdentifier("onboarding.ios.header-container")
            .padding(.horizontal, 22)
            .padding(.top, 22)

          Spacer(minLength: context.topSectionSpacing)

          OnboardingHorizontalCapabilityStrip(
            chips: context.capabilityChips,
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion,
            spacing: 8,
            chipPadding: 12,
            identifierPrefix: "onboarding.ios.capabilities"
          )
          .padding(.horizontal, 22)

          Spacer(minLength: context.heroSectionSpacing)

          OnboardingIOSHeroView(
            context: context,
            onContinue: onContinue
          )
          .accessibilityIdentifier("onboarding.ios.hero-container")
          .padding(.horizontal, 28)

          Spacer(minLength: context.footerSectionSpacing)

          OnboardingIOSFooterView(context: context)
            .accessibilityIdentifier("onboarding.ios.footer-container")
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
      }

      OnboardingSupportingNote(
        text: "OpenSpace is designed for developers who move between coding, visual ideation, and model orchestration.",
        hasAppeared: context.hasAppeared,
        alignment: .center,
        maxWidth: context.supportingNoteMaxWidth
      )
      .accessibilityIdentifier("onboarding.ios.supporting-note")
      .padding(.horizontal, 28)
      .padding(.bottom, 20)
    }
    .accessibilityIdentifier("onboarding.ios.content")
  }
}

#Preview("iPhone Onboarding Content") {
  OnboardingIOSView(
    context: OnboardingPreviewSupport.context(
      variant: .ios,
      size: CGSize(width: 390, height: 844)
    ),
    onContinue: {}
  )
  .padding(.vertical, 18)
  .onboardingPreviewSurface(size: CGSize(width: 390, height: 844))
}
