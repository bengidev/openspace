//
//  OnboardingMacHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeroView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    ViewThatFits(in: .horizontal) {
      wideLayout
      stackedLayout
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("onboarding.mac.hero")
  }

  private var wideLayout: some View {
    HStack(alignment: .top, spacing: context.heroStackSpacing + 28) {
      leadingColumn
      secondaryColumn
        .frame(width: context.desktopSidebarWidth, alignment: .leading)
    }
  }

  private var stackedLayout: some View {
    VStack(alignment: .leading, spacing: context.heroStackSpacing) {
      leadingColumn
      secondaryColumn
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var leadingColumn: some View {
    VStack(alignment: .leading, spacing: context.heroContentSpacing) {
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
      .padding(.bottom, context.macSpacingAfterCapabilities)

      VStack(alignment: .leading, spacing: 8) {
        Text("A Native Desktop Surface for Multi-Provider Work")
          .font(.system(size: context.heroTitleSize, weight: .medium, design: .default))
          .multilineTextAlignment(.leading)
          .foregroundStyle(Color.white)
          .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
          .frame(maxWidth: context.heroTextMaxWidth, alignment: .leading)
          .lineLimit(4)
          .minimumScaleFactor(0.8)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 18)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.mac.hero.title")

        Text("The macOS family keeps onboarding logic shared while producing a different render family: denser chrome, stronger information scent, and room for a real desktop posture.")
          .font(context.heroSubtitleFont)
          .multilineTextAlignment(.leading)
          .foregroundStyle(Color.white.opacity(0.8))
          .frame(maxWidth: context.heroSupportingTextMaxWidth, alignment: .leading)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 14)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
            value: context.hasAppeared
          )
          .accessibilityIdentifier("onboarding.mac.hero.subtitle")
      }
      .padding(.top, context.macSpacingAfterHeroCopy + 30)
        
        Spacer()

      actionCluster
            .padding(.bottom, 30)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var actionCluster: some View {
    VStack(alignment: .leading, spacing: 16) {
      OnboardingPrimaryButton(
        title: "Enter OpenSpace",
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        minWidth: context.heroSupportingTextMaxWidth,
        minHeight: 28,
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
          .foregroundStyle(Color.white.opacity(0.82))

        Spacer(minLength: 10)

        compactStatus("DESKTOP-FIRST")
      }

      Rectangle()
        .fill(Color.white.opacity(0.08))
        .frame(height: 1)
        .padding(.vertical, 2)

      VStack(alignment: .leading, spacing: 8) {
        OnboardingMacDetailRow(title: "Hierarchy", value: "Persistent panels and cues")
        OnboardingMacDetailRow(title: "Setup", value: "Local AI staged in first run")
        OnboardingMacDetailRow(title: "Render", value: "Shared flow, desktop-aware surface")
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
    VStack(alignment: .leading, spacing: 14) {
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
          .foregroundStyle(Color.white.opacity(0.72))

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
        statTile(value: "1", label: "shared flow")
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
            .foregroundStyle(Color.white.opacity(0.82))

          Spacer(minLength: 8)

          desktopMetricStrip
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Desktop Notes")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.white.opacity(0.82))

          desktopMetricStrip
        }
      }

      VStack(alignment: .leading, spacing: 8) {
        OnboardingMacDetailRow(title: "Chrome", value: "Persistent workspace framing")
        OnboardingMacDetailRow(title: "Density", value: "More information per surface")
        OnboardingMacDetailRow(title: "Flow", value: "Shared state, variant-specific render")
      }
    }
    .padding(14)
    .background(cardBackground(opacity: 0.10))
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier("onboarding.mac.hero.notes-card")
  }

  private var desktopMetricStrip: some View {
    HStack(spacing: 8) {
      compactMetric(title: "Flow", value: "Shared state")
        .frame(maxWidth: .infinity, alignment: .leading)

      compactMetric(title: "Density", value: "Desktop-first")
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func compactMetric(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(Color.white.opacity(0.58))

      Text(value)
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.white.opacity(0.92))
        .lineLimit(1)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(cardBackground(opacity: 0.12))
  }

  private func compactStatus(_ title: String) -> some View {
    Text(title)
      .font(.caption2.monospaced().weight(.medium))
      .foregroundStyle(Color.white.opacity(0.90))
      .padding(.horizontal, 8)
      .padding(.vertical, 5)
      .background(Capsule().fill(Color.white.opacity(0.14)))
  }

  private func sessionRow(icon: String, title: String, value: String) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: icon)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Color.white.opacity(0.82))
        .frame(width: 26, height: 26)
        .background(Circle().fill(Color.white.opacity(0.10)))

      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.caption.weight(.semibold))
          .foregroundStyle(Color.white.opacity(0.85))

        Text(value)
          .font(.footnote)
          .foregroundStyle(Color.white.opacity(0.92))
      }
    }
  }

  private func statTile(value: String, label: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(value)
        .font(.title3.weight(.semibold))
        .foregroundStyle(Color.white)

      Text(label)
        .font(.caption2)
        .foregroundStyle(Color.white.opacity(0.78))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color.black.opacity(0.18))
    )
  }

  private func cardBackground(opacity: Double) -> some View {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
      .fill(Color.white.opacity(opacity))
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
      )
  }
}

private struct OnboardingMacDetailRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(Color.white.opacity(0.58))
        .frame(width: 74, alignment: .leading)

      Text(value)
        .font(.footnote)
        .foregroundStyle(Color.white.opacity(0.90))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

#Preview("Desktop Hero") {
  OnboardingMacHeroView(
    context: OnboardingPreviewSupport.context(
      variant: .mac,
      size: CGSize(width: 1120, height: 620)
    ),
    onContinue: {}
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 1120, height: 460))
}
