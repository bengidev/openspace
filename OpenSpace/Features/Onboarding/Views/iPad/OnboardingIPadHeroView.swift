//
//  OnboardingIPadHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeroView: View {
  @Environment(\.colorScheme) private var colorScheme
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

        Text("iPad onboarding keeps the path simple, but uses the larger surface for clearer grouping, stronger feature cues, and a calmer handoff into the app.")
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

  private var capabilityColumn: some View {
    VStack(spacing: layout.heroCardSpacing) {
      featureCard(
        title: "Focused Entry",
        caption: "One clear primary action",
        icon: "point.topleft.down.curvedto.point.bottomright.up"
      ) {
        detailRow(title: "Entry", value: "Fewer branches before work starts")
        detailRow(title: "Rhythm", value: "Context stays visible without crowding")
      }

      featureCard(
        title: "Glanceable Setup",
        caption: "More room for orientation",
        icon: "square.grid.2x2"
      ) {
        detailRow(title: "Capabilities", value: "Code, images, research, and automation")
        detailRow(title: "Surface", value: "Optimized for touch and split attention")
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

  private func featureCard<Content: View>(
    title: String,
    caption: String,
    icon: String,
    @ViewBuilder content: () -> Content
    ) -> some View {
    VStack(alignment: .leading, spacing: layout.heroCardInternalSpacing) {
      HStack(alignment: .center, spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
          .frame(width: 34, height: 34)
          .background(Circle().fill(ThemeColor.subtlePanelFill(for: colorScheme)))

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.headline)
            .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))

          Text(caption)
            .font(.caption)
            .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
        }
      }

      content()
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(cardBackground)
  }

  private func detailRow(title: String, value: String) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: 82, alignment: .leading)

      Text(value)
        .font(.footnote)
        .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var cardBackground: some View {
    RoundedRectangle(cornerRadius: 24, style: .continuous)
      .fill(colorScheme == .dark ? Color.white.opacity(0.09) : ThemeColor.accent100.opacity(0.54))
      .overlay(
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .strokeBorder(ThemeColor.chromeStroke(for: colorScheme), lineWidth: 1)
      )
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
    onContinue: {}
  )
  .padding(32)
  .onboardingPreviewSurface(size: CGSize(width: 834, height: 430))
}
