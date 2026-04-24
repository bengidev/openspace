//
//  OnboardingIOSHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSHeroView: View {
    // MARK: Internal

    let context: OnboardingRenderContext
    let layout: OnboardingIOSLayout
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            OnboardingSignalPill(
                isAnimated: context.isAnimated,
                label: "A pocket-sized workspace for code, images, and AI tasks",
                identifierPrefix: "onboarding.ios.hero.signal"
            )
            .padding(.horizontal, layout.heroSignalHorizontalPadding)
            .padding(.top, layout.heroTopPadding)

            Spacer(minLength: layout.heroTopSpacer)

            VStack(spacing: layout.heroTextSpacing) {
                Text("Calm Systems for Fast Builders")
                    .font(.system(size: layout.heroTitleSize, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
                    .frame(maxWidth: layout.heroTextMaxWidth)
                    .minimumScaleFactor(0.8)
                    .opacity(context.hasAppeared ? 1 : 0)
                    .offset(y: context.hasAppeared ? 0 : 18)
                    .animation(
                        .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
                        value: context.hasAppeared
                    )
                    .accessibilityIdentifier("onboarding.ios.hero.title")

                Text(
                    "OpenSpace gives iPhone a tighter first-run rhythm: clear intent, less chrome, and one fast path into the workspace."
                )
                .font(layout.heroSubtitleFont)
                .multilineTextAlignment(.center)
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
                .frame(maxWidth: layout.heroSupportingTextMaxWidth)
                .opacity(context.hasAppeared ? 1 : 0)
                .offset(y: context.hasAppeared ? 0 : 14)
                .animation(
                    .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
                    value: context.hasAppeared
                )
                .accessibilityIdentifier("onboarding.ios.hero.subtitle")
            }

            Spacer(minLength: layout.heroBottomSpacer)

            OnboardingPrimaryButton(
                title: "Enter OpenSpace",
                hasAppeared: context.hasAppeared,
                reduceMotion: context.reduceMotion,
                font: layout.heroPrimaryButtonFont,
                minHeight: layout.heroPrimaryButtonMinHeight,
                horizontalPadding: layout.heroPrimaryButtonHorizontalPadding,
                verticalPadding: layout.heroPrimaryButtonVerticalPadding,
                identifier: "onboarding.ios.hero.primary-action",
                action: onContinue
            )
            .padding(.bottom, layout.heroBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, layout.heroHorizontalPadding)
        .accessibilityIdentifier("onboarding.ios.hero")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("iPhone Hero") {
    OnboardingIOSHeroView(
        context: OnboardingPreviewSupport.context(
            variant: .ios,
            size: CGSize(width: 390, height: 844)
        ),
        layout: OnboardingIOSLayout(
            context: OnboardingPreviewSupport.context(
                variant: .ios,
                size: CGSize(width: 390, height: 844)
            )
        ),
        onContinue: { }
    )
    .padding(28)
    .onboardingPreviewSurface(size: CGSize(width: 390, height: 380))
}
