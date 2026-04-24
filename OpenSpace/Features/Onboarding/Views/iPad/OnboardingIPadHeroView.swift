//
//  OnboardingIPadHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeroView: View {
    // MARK: Internal

    let context: OnboardingRenderContext
    let layout: OnboardingIPadLayout
    let onContinue: () -> Void

    var body: some View {
        Group {
            if layout.prefersStackedHero {
                stackedHero
            } else {
                wideHero
            }
        }
        .accessibilityIdentifier("onboarding.ipad.hero")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var wideHero: some View {
        HStack(alignment: .center, spacing: layout.heroColumnSpacing) {
            copyColumn(alignment: .leading, isLeadingAligned: true)
                .frame(maxWidth: layout.heroCopyColumnMaxWidth, alignment: .leading)

            capabilityColumn
                .frame(width: layout.heroCardColumnWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stackedHero: some View {
        VStack(spacing: layout.heroColumnSpacing) {
            copyColumn(alignment: .center, isLeadingAligned: false)
            capabilityColumn
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var capabilityColumn: some View {
        VStack(spacing: layout.heroCardSpacing) {
            OnboardingIPadFeatureCard(
                title: "Focused Entry",
                caption: "One clear primary action",
                icon: "point.topleft.down.curvedto.point.bottomright.up",
                spacing: layout.heroCardInternalSpacing
            ) {
                OnboardingIPadDetailRow(title: "Entry", value: "Fewer branches before work starts")
                OnboardingIPadDetailRow(title: "Rhythm", value: "Context stays visible without crowding")
            }

            OnboardingIPadFeatureCard(
                title: "Glanceable Setup",
                caption: "More room for orientation",
                icon: "square.grid.2x2",
                spacing: layout.heroCardInternalSpacing
            ) {
                OnboardingIPadDetailRow(title: "Capabilities", value: "Code, images, research, and automation")
                OnboardingIPadDetailRow(title: "Surface", value: "Optimized for touch and split attention")
            }
        }
        .opacity(context.hasAppeared ? 1 : 0)
        .offset(x: context.hasAppeared ? 0 : 18)
        .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.34),
            value: context.hasAppeared
        )
        .accessibilityIdentifier("onboarding.ipad.hero.capability-column")
    }

    private func copyColumn(alignment: HorizontalAlignment, isLeadingAligned: Bool) -> some View {
        VStack(alignment: alignment, spacing: layout.heroCopySpacing) {
            OnboardingSignalPill(
                isAnimated: context.isAnimated,
                label: "A broader canvas for code, images, and local AI setup",
                identifierPrefix: "onboarding.ipad.hero.signal"
            )

            VStack(alignment: alignment, spacing: layout.heroTextBlockSpacing) {
                Text("A Real Workspace Posture From the First Screen")
                    .font(.system(size: layout.heroTitleSize, weight: .medium, design: .default))
                    .multilineTextAlignment(isLeadingAligned ? .leading : .center)
                    .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
                    .frame(maxWidth: layout.heroTextMaxWidth, alignment: isLeadingAligned ? .leading : .center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                    .opacity(context.hasAppeared ? 1 : 0)
                    .offset(y: context.hasAppeared ? 0 : 18)
                    .animation(
                        .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
                        value: context.hasAppeared
                    )
                    .accessibilityIdentifier("onboarding.ipad.hero.title")

                Text(
                    "iPad onboarding keeps the path simple, but uses the larger surface for clearer grouping, stronger feature cues, and a calmer handoff into the app."
                )
                .font(layout.heroSubtitleFont)
                .multilineTextAlignment(isLeadingAligned ? .leading : .center)
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
                .frame(maxWidth: layout.heroSupportingTextMaxWidth, alignment: isLeadingAligned ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
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
                font: layout.heroPrimaryButtonFont,
                minHeight: layout.heroPrimaryButtonMinHeight,
                horizontalPadding: layout.heroPrimaryButtonHorizontalPadding,
                verticalPadding: layout.heroPrimaryButtonVerticalPadding,
                identifier: "onboarding.ipad.hero.primary-action",
                action: onContinue
            )
            .padding(.top, layout.heroActionTopSpacing)
            .frame(maxWidth: .infinity, alignment: isLeadingAligned ? .leading : .center)
        }
        .frame(maxWidth: .infinity, alignment: isLeadingAligned ? .leading : .center)
    }
}

#Preview("iPad Hero") {
    let context = OnboardingPreviewSupport.context(
        variant: .ipad,
        size: CGSize(width: 834, height: 1194),
        capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
    )

    OnboardingIPadHeroView(
        context: context,
        layout: OnboardingIPadLayout(context: context),
        onContinue: { }
    )
    .padding(32)
    .onboardingPreviewSurface(size: CGSize(width: 834, height: 430))
}
