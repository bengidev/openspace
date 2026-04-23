//
//  OnboardingMacHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeroView: View {
  @Environment(\.colorScheme) private var colorScheme
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

        Text("OpenSpace uses macOS onboarding to frame the workspace early: more cues, more durable chrome, and a clearer sense of what stays visible once the app opens.")
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

      Spacer(minLength: 0)

      actionCluster
        .padding(.bottom, layout.actionBottomPadding)
    }
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
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .center, spacing: 10) {
        Text("Desktop Rhythm")
          .font(.caption.weight(.semibold))
          .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

        Spacer(minLength: 10)

        compactStatus("DESKTOP-FIRST")
      }

      Rectangle()
        .fill(ThemeColor.chromeStroke(for: colorScheme))
        .frame(height: 1)
        .padding(.vertical, 2)

      VStack(alignment: .leading, spacing: 8) {
        OnboardingMacDetailRow(title: "Hierarchy", value: "Persistent panels and cues")
        OnboardingMacDetailRow(title: "Setup", value: "Local AI staged in first run")
        OnboardingMacDetailRow(title: "Render", value: "Desktop-aware surface and pacing")
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(cardBackground(opacity: 0.10))
    .opacity(context.hasAppeared ? 1 : 0)
    .offset(y: context.hasAppeared ? 0 : 10)
    .animation(
      .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.36),
      value: context.hasAppeared
    )
    .accessibilityIdentifier("onboarding.mac.hero.workflow-highlights")
  }

  private var secondaryColumn: some View {
    VStack(alignment: .leading, spacing: layout.cardStackSpacing) {
      sessionSurfaceCard
      desktopNotesCard
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

  private var sessionSurfaceCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center) {
        Text("Workspace Surface")
          .font(.caption.weight(.semibold))
          .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

        Spacer()

        compactStatus("LIVE")
      }

      VStack(alignment: .leading, spacing: 8) {
        sessionRow(icon: "sidebar.leading", title: "Chrome", value: "Pinned navigation and durable context")
        sessionRow(icon: "square.stack.3d.up", title: "Providers", value: "Code, images, research, and automation")
        sessionRow(icon: "cpu", title: "Setup", value: "Local AI staging with a calmer first-run path")
      }

      HStack(spacing: 10) {
        statTile(value: "2x", label: "denser cues")
        statTile(value: "3", label: "desktop panes")
      }
    }
    .padding(14)
    .background(cardBackground(opacity: 0.12))
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("onboarding.mac.hero.workspace-card")
  }

  private var desktopNotesCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      ViewThatFits(in: .horizontal) {
        HStack(alignment: .top, spacing: 12) {
          Text("Desktop Notes")
            .font(.caption.weight(.semibold))
            .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

          Spacer(minLength: 8)

          desktopMetricStrip
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Desktop Notes")
            .font(.caption.weight(.semibold))
            .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

          desktopMetricStrip
        }
      }

      VStack(alignment: .leading, spacing: 8) {
        OnboardingMacDetailRow(title: "Chrome", value: "Persistent workspace framing")
        OnboardingMacDetailRow(title: "Density", value: "More information per surface")
        OnboardingMacDetailRow(title: "Flow", value: "Desktop-first entry posture")
      }
    }
    .padding(14)
    .background(cardBackground(opacity: 0.10))
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("onboarding.mac.hero.notes-card")
  }

  private var desktopMetricStrip: some View {
    HStack(spacing: 8) {
      compactMetric(title: "Flow", value: "Focused entry")
        .frame(maxWidth: .infinity, alignment: .leading)

      compactMetric(title: "Density", value: "Desktop-first")
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func compactMetric(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))

      Text(value)
        .font(.caption.weight(.semibold))
        .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
        .lineLimit(1)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(cardBackground(opacity: 0.12))
  }

  private func compactStatus(_ title: String) -> some View {
    Text(title)
      .font(.caption2.monospaced().weight(.medium))
      .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
      .padding(.horizontal, 8)
      .padding(.vertical, 5)
      .background(Capsule().fill(ThemeColor.subtlePanelFill(for: colorScheme)))
  }

  private func sessionRow(icon: String, title: String, value: String) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: icon)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
        .frame(width: 26, height: 26)
        .background(Circle().fill(ThemeColor.subtlePanelFill(for: colorScheme)))

      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.caption.weight(.semibold))
          .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

        Text(value)
          .font(.footnote)
          .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
      }
    }
  }

  private func statTile(value: String, label: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value)
        .font(.title3.weight(.semibold))
        .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))

      Text(label)
        .font(.caption2)
        .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(ThemeColor.subtlePanelFill(for: colorScheme))
    )
  }

  private func cardBackground(opacity: Double) -> some View {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
      .fill(colorScheme == .dark ? Color.white.opacity(opacity) : ThemeColor.accent100.opacity(max(opacity * 5.5, 0.42)))
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .strokeBorder(ThemeColor.chromeStroke(for: colorScheme), lineWidth: 1)
      )
  }
}

private struct OnboardingMacDetailRow: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: 74, alignment: .leading)

      Text(value)
        .font(.footnote)
        .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
        .fixedSize(horizontal: false, vertical: true)
    }
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
    onContinue: {}
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 1120, height: 460))
}
