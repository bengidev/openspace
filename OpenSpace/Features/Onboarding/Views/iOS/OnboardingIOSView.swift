//
//  OnboardingIOSView.swift
//  OpenSpace
//

import SwiftUI

struct OnboardingIOSView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  private var layout: OnboardingIOSLayout {
    OnboardingIOSLayout(context: context)
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: layout.screenStackSpacing) {
        Spacer(minLength: layout.screenTopSpacing)

        OnboardingAnimatedPanel(
          cornerRadius: layout.panelCornerRadius,
          maxWidth: layout.panelMaxWidth,
          minHeight: layout.panelMinHeight,
          horizontalPadding: layout.panelHorizontalPadding,
          hasAppeared: context.hasAppeared,
          reduceMotion: context.reduceMotion,
          isAnimated: context.isAnimated,
          identifierPrefix: "onboarding.ios"
        ) {
          VStack(spacing: 0) {
            OnboardingIOSHeaderView()
              .accessibilityIdentifier("onboarding.ios.header-container")
              .padding(.horizontal, layout.headerHorizontalPadding)
              .padding(.top, layout.headerTopPadding)

            OnboardingCapabilityStrip(
              chips: context.capabilityChips,
              hasAppeared: context.hasAppeared,
              reduceMotion: context.reduceMotion,
              spacing: layout.capabilitySpacing,
              chipPadding: layout.capabilityChipPadding,
              identifierPrefix: "onboarding.ios.capabilities"
            )
            .padding(.top, layout.capabilityTopPadding)
            .padding(.horizontal, layout.capabilityHorizontalPadding)

            OnboardingIOSHeroView(
              context: context,
              layout: layout,
              onContinue: onContinue
            )
            .accessibilityIdentifier("onboarding.ios.hero-container")

            Spacer(minLength: layout.footerTopSpacing)

            OnboardingFooterView(
              labels: ["FIRST-RUN ONBOARDING", "FUTURISTIC CALM", "LOCAL-FIRST"],
              hasAppeared: context.hasAppeared,
              alignment: .center,
              identifierPrefix: "onboarding.ios"
            )
            .accessibilityIdentifier("onboarding.ios.footer-container")
            .padding(.horizontal, layout.footerHorizontalPadding)
            .padding(.bottom, layout.footerBottomPadding)
          }
        }

        OnboardingSupportingNote(
          text: "OpenSpace keeps first-run setup calm on iPhone, so you can understand the workspace quickly and keep momentum when you enter the app.",
          hasAppeared: context.hasAppeared,
          alignment: .center,
          maxWidth: layout.supportingNoteMaxWidth
        )
        .accessibilityIdentifier("onboarding.ios.supporting-note")
        .padding(.horizontal, layout.supportingNoteHorizontalPadding)
        .padding(.bottom, layout.supportingNoteBottomPadding)
      }
      .frame(
        maxWidth: .infinity,
        minHeight: layout.screenContentMinHeight,
        alignment: .top
      )
    }
    .safeAreaPadding(.vertical, layout.screenVerticalPadding)
    .accessibilityIdentifier("onboarding.ios.scroll")
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
