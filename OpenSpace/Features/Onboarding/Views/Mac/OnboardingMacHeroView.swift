//
//  OnboardingMacHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeroView: View {
    // MARK: Internal

    let context: OnboardingRenderContext
    let layout: OnboardingMacLayout
    let onContinue: () -> Void

    var body: some View {
        Group {
            if layout.prefersStackedHero {
                stackedLayout
            } else {
                wideLayout
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("onboarding.mac.hero")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var wideLayout: some View {
        HStack(alignment: .top, spacing: layout.heroColumnSpacing) {
            leadingColumn
            secondaryColumn
                .frame(width: layout.secondaryColumnWidth, alignment: .leading)
        }
    }

    private var stackedLayout: some View {
        VStack(alignment: .leading, spacing: layout.heroColumnSpacing) {
            leadingColumn
            secondaryColumn
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var leadingColumn: some View {
        VStack(alignment: .leading, spacing: layout.heroContentSpacing) {
            OnboardingSignalPill(
                isAnimated: context.isAnimated,
                label: "A desktop workbench for coding, image generation, and local AI setup",
                identifierPrefix: "onboarding.mac.hero.signal"
            )
            .padding(.bottom, 6)

            OnboardingMacCapabilityStrip(
                chips: context.capabilityChips,
                hasAppeared: context.hasAppeared,
                reduceMotion: context.reduceMotion,
                identifierPrefix: "onboarding.mac.capabilities"
            )
            .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 8) {
                Text("A Native Desktop Entry for Multi-Tool Work")
                    .font(.system(size: layout.heroTitleSize, weight: .medium, design: .default))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
                    .shadow(color: ThemeColor.elevatedShadow(for: colorScheme), radius: 8, x: 0, y: 3)
                    .frame(maxWidth: layout.heroTextMaxWidth, alignment: .leading)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
                    .opacity(context.hasAppeared ? 1 : 0)
                    .offset(y: context.hasAppeared ? 0 : 18)
                    .animation(
                        .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
                        value: context.hasAppeared
                    )
                    .accessibilityIdentifier("onboarding.mac.hero.title")

                Text(
                    "OpenSpace uses macOS onboarding to frame the workspace early: more cues, more durable chrome, and a clearer sense of what stays visible once the app opens."
                )
                .font(layout.heroSubtitleFont)
                .multilineTextAlignment(.leading)
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
                .frame(maxWidth: layout.heroSupportingTextMaxWidth, alignment: .leading)
                .opacity(context.hasAppeared ? 1 : 0)
                .offset(y: context.hasAppeared ? 0 : 14)
                .animation(
                    .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
                    value: context.hasAppeared
                )
                .accessibilityIdentifier("onboarding.mac.hero.subtitle")
            }
            .padding(.top, layout.titleTopPadding)

            actionCluster
                .padding(.top, layout.actionTopPadding)
                .padding(.bottom, layout.actionBottomPadding)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionCluster: some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingPrimaryButton(
                title: "Enter OpenSpace",
                hasAppeared: context.hasAppeared,
                reduceMotion: context.reduceMotion,
                font: layout.heroPrimaryButtonFont,
                minWidth: layout.heroPrimaryButtonMinWidth,
                minHeight: layout.heroPrimaryButtonMinHeight,
                horizontalPadding: layout.heroPrimaryButtonHorizontalPadding,
                verticalPadding: layout.heroPrimaryButtonVerticalPadding,
                identifier: "onboarding.mac.hero.primary-action",
                action: onContinue
            )
        }
        .accessibilityIdentifier("onboarding.mac.hero.actions")
    }

    private var workflowHighlights: some View {
        OnboardingMacWorkflowHighlightsCard(
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion
        )
    }

    private var secondaryColumn: some View {
        VStack(alignment: .leading, spacing: layout.cardStackSpacing) {
            OnboardingMacSessionSurfaceCard()
            OnboardingMacDesktopNotesCard()
            workflowHighlights
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .opacity(context.hasAppeared ? 1 : 0)
        .offset(x: context.hasAppeared ? 0 : 18)
        .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.32),
            value: context.hasAppeared
        )
        .accessibilityIdentifier("onboarding.mac.hero.secondary-column")
    }
}

#Preview("Desktop Hero") {
    let context = OnboardingPreviewSupport.context(
        variant: .mac,
        size: CGSize(width: 1120, height: 620)
    )

    OnboardingMacHeroView(
        context: context,
        layout: OnboardingMacLayout(context: context),
        onContinue: { }
    )
    .padding(24)
    .onboardingComponentPreviewSurface()
}
