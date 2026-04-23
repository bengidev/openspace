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

  private var layout: OnboardingMacLayout {
    OnboardingMacLayout(context: context)
  }

  var body: some View {
    VStack(spacing: 0) {
      OnboardingPlatformPanel(
        variant: .mac,
        cornerRadius: layout.panelCornerRadius,
        maxWidth: layout.panelMaxWidth,
        minHeight: layout.panelMinHeight,
        horizontalPadding: layout.panelHorizontalPadding,
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        isAnimated: context.isAnimated,
        contentAlignment: .topLeading
      ) {
        VStack(alignment: .leading, spacing: layout.sectionSpacing) {
          OnboardingMacHeaderView()
            .accessibilityIdentifier("onboarding.mac.header-container")

          OnboardingMacHeroView(
            context: context,
            layout: layout,
            onContinue: onContinue
          )
          .accessibilityIdentifier("onboarding.mac.hero-container")

          VStack(alignment: .leading, spacing: 10) {
            OnboardingMacFooterView(context: context)
              .accessibilityIdentifier("onboarding.mac.footer-container")

            OnboardingSupportingNote(
              text: "macOS onboarding leans into a desktop workbench posture, with enough structure to orient you before the main workspace opens.",
              hasAppeared: context.hasAppeared,
              alignment: .leading,
              maxWidth: layout.supportingNoteMaxWidth
            )
            .accessibilityIdentifier("onboarding.mac.supporting-note")
          }
          .padding(.top, layout.footerTopPadding)
          .overlay(alignment: .top) {
            Rectangle()
              .fill(ThemeColor.chromeStroke(for: colorScheme))
              .frame(height: 1)
          }
        }
        .padding(.horizontal, layout.panelHorizontalInset)
        .padding(.top, layout.panelTopPadding)
        .padding(.bottom, layout.panelBottomPadding)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
