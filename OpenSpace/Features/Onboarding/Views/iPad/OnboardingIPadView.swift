//
//  OnboardingIPadView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      OnboardingPlatformPanel(variant: .ipad, context: context) {
        VStack(spacing: 0) {
          OnboardingIPadHeaderView()
            .accessibilityIdentifier("onboarding.ipad.header-container")
            .padding(.horizontal, 22)
            .padding(.top, 22)

          Spacer(minLength: context.topSectionSpacing)

          OnboardingHorizontalCapabilityStrip(
            chips: context.capabilityChips + ["Multiplatform", "Local-First"],
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion,
            spacing: 10,
            chipPadding: 14,
            identifierPrefix: "onboarding.ipad.capabilities"
          )
          .padding(.horizontal, 22)

          Spacer(minLength: context.heroSectionSpacing)

          OnboardingIPadHeroView(
            context: context,
            onContinue: onContinue
          )
          .accessibilityIdentifier("onboarding.ipad.hero-container")
          .padding(.horizontal, 28)

          Spacer(minLength: context.footerSectionSpacing)

          OnboardingIPadFooterView(context: context)
            .accessibilityIdentifier("onboarding.ipad.footer-container")
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
      }

      OnboardingSupportingNote(
        text: "The iPad family can afford broader composition, denser capability cues, and more persistent ambient context while keeping the same onboarding intent.",
        hasAppeared: context.hasAppeared,
        alignment: .center,
        maxWidth: context.supportingNoteMaxWidth
      )
      .accessibilityIdentifier("onboarding.ipad.supporting-note")
      .padding(.horizontal, 28)
      .padding(.bottom, 20)
    }
    .accessibilityIdentifier("onboarding.ipad.content")
  }
}

#Preview("iPad Onboarding Content") {
  OnboardingIPadView(
    context: OnboardingPreviewSupport.context(
      variant: .ipad,
      size: CGSize(width: 834, height: 1194),
      capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
    ),
    onContinue: {}
  )
  .padding(.vertical, 24)
  .onboardingPreviewSurface(size: CGSize(width: 834, height: 1194))
}
