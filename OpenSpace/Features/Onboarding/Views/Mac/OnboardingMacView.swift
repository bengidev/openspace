//
//  OnboardingMacView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacView: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    OnboardingPlatformPanel(variant: .mac, context: context) {
      VStack(alignment: .leading, spacing: context.desktopSectionSpacing) {
        OnboardingMacHeaderView()
          .accessibilityIdentifier("onboarding.mac.header-container")

        OnboardingMacHeroView(
          context: context,
          onContinue: onContinue
        )
        .accessibilityIdentifier("onboarding.mac.hero-container")

        VStack(alignment: .leading, spacing: 10) {
          OnboardingMacFooterView(context: context)
            .accessibilityIdentifier("onboarding.mac.footer-container")

          OnboardingSupportingNote(
            text: "The macOS surface leans into dense desktop posture: shared onboarding logic, stronger workspace framing, and room for durable chrome without feeling heavy.",
            hasAppeared: context.hasAppeared,
            alignment: .leading,
            maxWidth: context.supportingNoteMaxWidth
          )
          .accessibilityIdentifier("onboarding.mac.supporting-note")
        }
        .padding(.top, context.macSpacingBeforeFooter)
        .overlay(alignment: .top) {
          Rectangle()
            .fill(ThemeColor.chromeStroke(for: colorScheme))
            .frame(height: 1)
        }
      }
      .padding(.horizontal, context.desktopPanelPadding)
      .padding(.top, max(context.desktopPanelPadding - 4, 12))
      .padding(.bottom, max(context.desktopPanelPadding - 20, 6))
    }
    .accessibilityIdentifier("onboarding.mac.content")
  }
}

#Preview("Desktop Onboarding Content") {
  OnboardingMacView(
    context: OnboardingPreviewSupport.context(
      variant: .mac,
      size: CGSize(width: 1120, height: 620)
    ),
    onContinue: {}
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 1120, height: 620))
}
