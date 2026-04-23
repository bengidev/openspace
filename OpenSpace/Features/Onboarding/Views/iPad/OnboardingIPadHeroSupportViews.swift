//
//  OnboardingIPadHeroSupportViews.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct OnboardingIPadFeatureCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let caption: String
  let icon: String
  let spacing: CGFloat
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
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

      content
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(cardBackground)
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

struct OnboardingIPadDetailRow: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let value: String

  var body: some View {
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
}

#Preview("iPad Feature Card") {
  OnboardingIPadFeatureCard(
    title: "Focused Entry",
    caption: "One clear primary action",
    icon: "point.topleft.down.curvedto.point.bottomright.up",
    spacing: 16
  ) {
    OnboardingIPadDetailRow(title: "Entry", value: "Fewer branches before work starts")
    OnboardingIPadDetailRow(title: "Rhythm", value: "Context stays visible without crowding")
  }
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 420, height: 260))
}
