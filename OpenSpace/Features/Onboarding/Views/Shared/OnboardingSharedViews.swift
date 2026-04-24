//
//  OnboardingSharedViews.swift
//  OpenSpace
//
//  Shared onboarding components across all platforms.
//

import SwiftUI

// MARK: - Animated Panel

struct OnboardingAnimatedPanel<Content: View>: View {
  let style: OnboardingHeroPanelStyle
  let cornerRadius: CGFloat
  let maxWidth: CGFloat?
  let minHeight: CGFloat
  let horizontalPadding: CGFloat
  let hasAppeared: Bool
  let reduceMotion: Bool
  let isAnimated: Bool
  let contentAlignment: Alignment
  let identifierPrefix: String
  @ViewBuilder let content: Content

  init(
    style: OnboardingHeroPanelStyle = .floatingShowcase,
    cornerRadius: CGFloat,
    maxWidth: CGFloat? = nil,
    minHeight: CGFloat,
    horizontalPadding: CGFloat,
    hasAppeared: Bool,
    reduceMotion: Bool,
    isAnimated: Bool = false,
    contentAlignment: Alignment = .center,
    identifierPrefix: String,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.horizontalPadding = horizontalPadding
    self.hasAppeared = hasAppeared
    self.reduceMotion = reduceMotion
    self.isAnimated = isAnimated
    self.contentAlignment = contentAlignment
    self.identifierPrefix = identifierPrefix
    self.content = content()
  }

  var body: some View {
    OnboardingHeroPanel(
      style: style,
      cornerRadius: cornerRadius
    ) {
      content
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: contentAlignment)
    }
    .frame(maxWidth: maxWidth)
    .padding(.horizontal, horizontalPadding)
    .opacity(hasAppeared ? 1 : 0)
    .offset(y: hasAppeared ? 0 : 26)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.9), value: hasAppeared)
    .modifier(
      FloatingPanelEffect(isActive: style == .floatingShowcase && isAnimated)
    )
    .accessibilityIdentifier("\(identifierPrefix).panel")
  }
}

// MARK: - Capability Strip

struct OnboardingCapabilityStrip: View {
  let chips: [String]
  let hasAppeared: Bool
  let reduceMotion: Bool
  let spacing: CGFloat
  let chipPadding: CGFloat
  let identifierPrefix: String

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: spacing) {
        ForEach(Array(chips.enumerated()), id: \.element) { index, chip in
          OnboardingCapabilityChip(
            title: chip,
            isVisible: hasAppeared,
            reduceMotion: reduceMotion,
            delay: Double(index) * 0.08,
            horizontalPadding: chipPadding,
            identifier: "\(identifierPrefix).chip.\(chip.onboardingIdentifierSlug)"
          )
        }
      }
    }
    .scrollClipDisabled()
    .accessibilityIdentifier(identifierPrefix)
  }
}

// MARK: - Supporting Note

struct OnboardingSupportingNote: View {
  @Environment(\.colorScheme) private var colorScheme
  let text: String
  let hasAppeared: Bool
  let alignment: TextAlignment
  let maxWidth: CGFloat?
  let frameAlignment: Alignment

  init(
    text: String,
    hasAppeared: Bool,
    alignment: TextAlignment,
    maxWidth: CGFloat? = nil,
    frameAlignment: Alignment = .center
  ) {
    self.text = text
    self.hasAppeared = hasAppeared
    self.alignment = alignment
    self.maxWidth = maxWidth
    self.frameAlignment = frameAlignment
  }

  var body: some View {
    Text(text)
      .font(.footnote)
      .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
      .multilineTextAlignment(alignment)
      .frame(maxWidth: maxWidth)
      .frame(maxWidth: .infinity, alignment: frameAlignment)
      .opacity(hasAppeared ? 1 : 0)
      .offset(y: hasAppeared ? 0 : 10)
      .animation(.easeOut(duration: 0.8).delay(0.55), value: hasAppeared)
  }
}

// MARK: - Footer View

struct OnboardingFooterView: View {
  let labels: [String]
  let hasAppeared: Bool
  let alignment: Alignment
  let identifierPrefix: String

  var body: some View {
    OnboardingMetadataBar(
      labels: labels,
      hasAppeared: hasAppeared,
      alignment: alignment,
      identifierPrefix: "\(identifierPrefix).footer"
    )
  }
}
