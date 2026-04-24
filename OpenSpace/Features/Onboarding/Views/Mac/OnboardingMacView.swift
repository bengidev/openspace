//
//  OnboardingMacView.swift
//  OpenSpace
//

import SwiftUI

struct OnboardingMacView: View {
    // MARK: Internal

    let context: OnboardingRenderContext
    let onContinue: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: layout.screenTopSpacing)

                OnboardingAnimatedPanel(
                    style: .desktopCanvas,
                    cornerRadius: layout.panelCornerRadius,
                    maxWidth: layout.panelMaxWidth,
                    minHeight: layout.panelMinHeight,
                    horizontalPadding: layout.panelHorizontalPadding,
                    hasAppeared: context.hasAppeared,
                    reduceMotion: context.reduceMotion,
                    isAnimated: false,
                    contentAlignment: .center,
                    identifierPrefix: "onboarding.mac"
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
                            OnboardingFooterView(
                                labels: ["LOCAL-FIRST WORKBENCH", "DESKTOP DENSITY", "MULTI-WINDOW READY"],
                                hasAppeared: context.hasAppeared,
                                alignment: .leading,
                                identifierPrefix: "onboarding.mac"
                            )
                            .accessibilityIdentifier("onboarding.mac.footer-container")
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
                    .frame(maxWidth: layout.contentMaxWidth, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: layout.screenContentMinHeight,
                alignment: .center
            )
        }
        .safeAreaPadding(.vertical, layout.screenVerticalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .clipped()
        .accessibilityIdentifier("onboarding.mac.scroll")
        .accessibilityIdentifier("onboarding.mac.content")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var layout: OnboardingMacLayout {
        OnboardingMacLayout(context: context)
    }
}

#Preview("Desktop Onboarding Content") {
    OnboardingMacView(
        context: OnboardingPreviewSupport.context(
            variant: .mac,
            size: CGSize(width: 1120, height: 620)
        ),
        onContinue: { }
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 1120, height: 620))
}
