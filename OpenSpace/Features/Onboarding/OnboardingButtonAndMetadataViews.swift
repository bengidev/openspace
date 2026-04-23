//
//  OnboardingButtonAndMetadataViews.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct OnboardingPrimaryButton: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let hasAppeared: Bool
  let reduceMotion: Bool
  let font: Font
  let minWidth: CGFloat?
  let minHeight: CGFloat
  let horizontalPadding: CGFloat
  let verticalPadding: CGFloat
  let identifier: String
  let action: () -> Void

  init(
    title: String,
    hasAppeared: Bool,
    reduceMotion: Bool,
    font: Font = .title3.weight(.semibold),
    minWidth: CGFloat? = nil,
    minHeight: CGFloat = 48,
    horizontalPadding: CGFloat = 28,
    verticalPadding: CGFloat = 18,
    identifier: String = "onboarding.primary-button",
    action: @escaping () -> Void
  ) {
    self.title = title
    self.hasAppeared = hasAppeared
    self.reduceMotion = reduceMotion
    self.font = font
    self.minWidth = minWidth
    self.minHeight = minHeight
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.identifier = identifier
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(font)
        .foregroundStyle(colorScheme == .dark ? ThemeColor.neutral1000 : ThemeColor.textPrimary)
        .frame(minWidth: minWidth, minHeight: minHeight)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
          Capsule()
            .fill(colorScheme == .dark ? Color.white : ThemeColor.accent100)
        )
    }
    .buttonStyle(.plain)
    .accessibilityHint("Finish onboarding and enter the current app shell")
    .accessibilityIdentifier(identifier)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.94))
    .opacity(hasAppeared ? 1 : 0)
    .shadow(
      color: ThemeColor.elevatedShadow(for: colorScheme).opacity(reduceMotion ? 0.45 : 1),
      radius: hasAppeared ? 12 : 0,
      x: 0,
      y: 5
    )
    .animation(
      .easeOut(duration: 0.75).delay(reduceMotion ? 0 : 0.38),
      value: hasAppeared
    )
    .modifier(
      AmbientBreathingEffect(
        isActive: !reduceMotion && hasAppeared
      )
    )
  }
}

struct OnboardingMetadataBar: View {
  @Environment(\.colorScheme) private var colorScheme
  let labels: [String]
  let hasAppeared: Bool
  let alignment: Alignment
  let identifierPrefix: String

  var body: some View {
    ViewThatFits(in: .horizontal) {
      horizontalBar
      verticalBar
    }
    .font(.caption2.monospaced())
    .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
    .opacity(hasAppeared ? 1 : 0)
    .animation(
      .easeOut(duration: 0.8).delay(0.48),
      value: hasAppeared
    )
    .accessibilityIdentifier(identifierPrefix)
  }

  private var horizontalBar: some View {
    HStack {
      ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
        if index > 0 {
          Spacer(minLength: 12)
        }

        labelView(label)
      }
    }
    .frame(maxWidth: .infinity, alignment: alignment)
  }

  private var verticalBar: some View {
    VStack(spacing: 8) {
      ForEach(labels, id: \.self) { label in
        labelView(label)
      }
    }
    .frame(maxWidth: .infinity, alignment: alignment)
  }

  private func labelView(_ label: String) -> some View {
    Text(label)
      .lineLimit(1)
      .minimumScaleFactor(0.78)
      .accessibilityIdentifier("\(identifierPrefix).label.\(label.onboardingIdentifierSlug)")
  }
}

#Preview("Onboarding Primary Button") {
  OnboardingPrimaryButton(
    title: "Enter OpenSpace",
    hasAppeared: true,
    reduceMotion: true,
    minWidth: 220,
    identifier: "preview.onboarding.primary"
  ) {}
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 420, height: 180))
}

#Preview("Onboarding Metadata Bar") {
  OnboardingMetadataBar(
    labels: ["IPAD WORKSPACE", "EXPANSIVE COMPOSITION", "FOCUS + BREADTH"],
    hasAppeared: true,
    alignment: .center,
    identifierPrefix: "preview.onboarding.metadata"
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 720, height: 160))
}
