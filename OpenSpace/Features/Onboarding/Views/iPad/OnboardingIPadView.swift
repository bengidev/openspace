//
//  OnboardingIPadView.swift
//  OpenSpace
//

import SwiftUI

struct OnboardingIPadView: View {
    // MARK: Internal

    let context: OnboardingRenderContext
    let onContinue: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: layout.screenStackSpacing) {
                OnboardingIPadAnimatedPanel(
                    cornerRadius: layout.panelCornerRadius,
                    maxWidth: layout.panelMaxWidth,
                    minHeight: 0,
                    horizontalPadding: layout.panelHorizontalPadding,
                    hasAppeared: context.hasAppeared,
                    reduceMotion: context.reduceMotion,
                    isAnimated: context.isAnimated,
                    identifierPrefix: "onboarding.ipad"
                ) {
                    VStack(spacing: 0) {
                        OnboardingIPadHeaderView()
                            .accessibilityIdentifier("onboarding.ipad.header-container")
                            .padding(.horizontal, layout.headerHorizontalPadding)
                            .padding(.top, layout.headerTopPadding)
                            .padding(.bottom, layout.heroBottomPadding)

                        OnboardingIPadCapabilityStrip(
                            chips: context.capabilityChips + ["Multiplatform", "Local-First"],
                            hasAppeared: context.hasAppeared,
                            reduceMotion: context.reduceMotion,
                            spacing: layout.capabilitySpacing,
                            chipPadding: layout.capabilityChipPadding,
                            identifierPrefix: "onboarding.ipad.capabilities"
                        )
                        .padding(.horizontal, layout.capabilityHorizontalPadding)

                        Spacer()
                            .frame(height: 100)

                        OnboardingIPadHeroView(
                            context: context,
                            layout: layout,
                            onContinue: onContinue
                        )
                        .accessibilityIdentifier("onboarding.ipad.hero-container")
                        .padding(.horizontal, layout.heroHorizontalPadding)
                        .padding(.bottom, layout.heroBottomPadding)

                        Spacer()
                            .frame(height: 50)

                        OnboardingIPadFooterView(
                            labels: ["IPAD WORKSPACE", "EXPANSIVE COMPOSITION", "FOCUS + BREADTH"],
                            hasAppeared: context.hasAppeared,
                            alignment: .center,
                            identifierPrefix: "onboarding.ipad"
                        )
                        .accessibilityIdentifier("onboarding.ipad.footer-container")
                        .padding(.horizontal, layout.footerHorizontalPadding)
                        .padding(.bottom, layout.footerBottomPadding)
                    }
                }

                OnboardingIPadSupportingNote(
                    text: "On iPad, onboarding uses the extra canvas for hierarchy and glanceable setup context, so the first screen already feels like a workspace instead of a blown-up phone sheet.",
                    hasAppeared: context.hasAppeared,
                    alignment: .center,
                    maxWidth: layout.supportingNoteMaxWidth
                )
                .accessibilityIdentifier("onboarding.ipad.supporting-note")
                .padding(.horizontal, layout.supportingNoteHorizontalPadding)
                .padding(.bottom, layout.supportingNoteBottomPadding)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: layout.screenContentMinHeight,
                alignment: .center
            )
        }
        .safeAreaPadding(.vertical, layout.screenVerticalPadding)
        .accessibilityIdentifier("onboarding.ipad.scroll")
        .accessibilityIdentifier("onboarding.ipad.content")
    }

    // MARK: Private

    private var layout: OnboardingIPadLayout {
        OnboardingIPadLayout(context: context)
    }
}

#Preview("iPad Onboarding Content") {
    OnboardingIPadView(
        context: OnboardingPreviewSupport.context(
            variant: .ipad,
            size: CGSize(width: 834, height: 1194),
            capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
        ),
        onContinue: { }
    )
    .padding(.vertical, 24)
    .onboardingPreviewSurface(size: CGSize(width: 834, height: 1194))
}
