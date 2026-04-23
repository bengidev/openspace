//
//  OnboardingSharedComponents.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

private extension String {
  var onboardingIdentifierSlug: String {
    lowercased()
      .map { character in
        character.isLetter || character.isNumber ? String(character) : "-"
      }
      .joined()
      .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
  }
}

struct OnboardingPlatformPanel<Content: View>: View {
  let variant: OnboardingPlatformVariant
  let cornerRadius: CGFloat
  let maxWidth: CGFloat?
  let minHeight: CGFloat
  let horizontalPadding: CGFloat
  let hasAppeared: Bool
  let reduceMotion: Bool
  let isAnimated: Bool
  let contentAlignment: Alignment
  @ViewBuilder let content: Content

  init(
    variant: OnboardingPlatformVariant,
    cornerRadius: CGFloat,
    maxWidth: CGFloat?,
    minHeight: CGFloat,
    horizontalPadding: CGFloat,
    hasAppeared: Bool,
    reduceMotion: Bool,
    isAnimated: Bool,
    contentAlignment: Alignment = .center,
    @ViewBuilder content: () -> Content
  ) {
    self.variant = variant
    self.cornerRadius = cornerRadius
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.horizontalPadding = horizontalPadding
    self.hasAppeared = hasAppeared
    self.reduceMotion = reduceMotion
    self.isAnimated = isAnimated
    self.contentAlignment = contentAlignment
    self.content = content()
  }

  var body: some View {
    OnboardingHeroPanel(
      style: variant.panelStyle,
      cornerRadius: cornerRadius
    ) {
      content
        .frame(
          maxWidth: .infinity,
          minHeight: minHeight,
          alignment: contentAlignment
        )
    }
    .frame(maxWidth: maxWidth)
    .padding(.horizontal, horizontalPadding)
    .opacity(hasAppeared ? 1 : 0)
    .offset(y: hasAppeared ? 0 : 26)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.9), value: hasAppeared)
    .modifier(
      FloatingPanelEffect(
        isActive: isAnimated && variant.usesFloatingPanelEffect
      )
    )
    .accessibilityIdentifier("\(variant.identifierPrefix).panel")
  }
}

struct OnboardingHeaderChromeView: View {
  @Environment(\.colorScheme) private var colorScheme
  let centerText: String
  let badgeOpacity: Double
  let buttonSize: CGFloat
  let identifierPrefix: String

  init(
    centerText: String,
    badgeOpacity: Double = 0.56,
    buttonSize: CGFloat = 36,
    identifierPrefix: String = "onboarding.header"
  ) {
    self.centerText = centerText
    self.badgeOpacity = badgeOpacity
    self.buttonSize = buttonSize
    self.identifierPrefix = identifierPrefix
  }

  var body: some View {
    ViewThatFits(in: .horizontal) {
      regularChrome
      compactChrome
    }
    .accessibilityIdentifier(identifierPrefix)
  }

  private var regularChrome: some View {
    HStack {
      leadingButton

      Spacer(minLength: 12)

      centerBadge

      Spacer(minLength: 12)

      trailingButton
    }
  }

  private var compactChrome: some View {
    VStack(spacing: 12) {
      HStack {
        leadingButton
        Spacer(minLength: 12)
        trailingButton
      }

      centerBadge
        .frame(maxWidth: .infinity)
    }
  }

  private var leadingButton: some View {
    Button {} label: {
      Image(systemName: "plus")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: buttonSize, height: buttonSize)
        .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("OpenSpace mark")
    .accessibilityIdentifier("\(identifierPrefix).leading-button")
  }

  private var centerBadge: some View {
    Text(centerText)
      .font(.caption.weight(.semibold))
      .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Capsule().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: badgeOpacity)))
      .accessibilityIdentifier("\(identifierPrefix).center-badge")
  }

  private var trailingButton: some View {
    Button {} label: {
      Image(systemName: "waveform.path.ecg")
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: buttonSize, height: buttonSize)
        .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Ambient activity indicator")
    .accessibilityIdentifier("\(identifierPrefix).trailing-button")
  }
}

struct OnboardingHorizontalCapabilityStrip: View {
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

struct OnboardingMacCapabilityStrip: View {
  let chips: [String]
  let hasAppeared: Bool
  let reduceMotion: Bool
  let identifierPrefix: String

  private let columns = [
    GridItem(.adaptive(minimum: 84), spacing: 8),
  ]

  var body: some View {
    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
      ForEach(Array(chips.enumerated()), id: \.element) { index, chip in
        OnboardingCapabilityChip(
          title: chip,
          isVisible: hasAppeared,
          reduceMotion: reduceMotion,
          delay: Double(index) * 0.06,
          horizontalPadding: 9,
          identifier: "\(identifierPrefix).chip.\(chip.onboardingIdentifierSlug)"
        )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityIdentifier(identifierPrefix)
  }
}

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

struct OnboardingSupportingNote: View {
  @Environment(\.colorScheme) private var colorScheme
  let text: String
  let hasAppeared: Bool
  let alignment: TextAlignment
  let maxWidth: CGFloat?

  var body: some View {
    Text(text)
      .font(.footnote)
      .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
      .multilineTextAlignment(alignment)
      .frame(maxWidth: maxWidth)
      .frame(maxWidth: .infinity, alignment: frameAlignment)
      .opacity(hasAppeared ? 1 : 0)
      .offset(y: hasAppeared ? 0 : 10)
      .animation(
        .easeOut(duration: 0.8).delay(0.55),
        value: hasAppeared
      )
  }

  private var frameAlignment: Alignment {
    switch alignment {
    case .leading:
      .leading
    case .trailing:
      .trailing
    default:
      .center
    }
  }
}

struct OnboardingCapabilityChip: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let isVisible: Bool
  let reduceMotion: Bool
  let delay: Double
  let horizontalPadding: CGFloat
  let identifier: String

  var body: some View {
    Text(title)
      .font(.caption.monospaced())
      .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, 6)
      .background(
        Capsule()
          .fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.1))
      )
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 10)
      .scaleEffect(reduceMotion ? 1 : (isVisible ? 1 : 0.96))
      .animation(
        .easeOut(duration: 0.55).delay(reduceMotion ? 0 : delay),
        value: isVisible
      )
      .accessibilityIdentifier(identifier)
  }
}

struct OnboardingSignalPill: View {
  @Environment(\.colorScheme) private var colorScheme
  let isAnimated: Bool
  let label: String
  let identifierPrefix: String

  init(
    isAnimated: Bool,
    label: String = "One workspace for coding, image generation, and local AI setup",
    identifierPrefix: String = "onboarding.signal-pill"
  ) {
    self.isAnimated = isAnimated
    self.label = label
    self.identifierPrefix = identifierPrefix
  }

  var body: some View {
    HStack(spacing: 8) {
      AnimatedSignalDot(
        isAnimated: isAnimated,
        identifier: "\(identifierPrefix).dot"
      )

      Text(label)
        .font(.caption)
        .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("\(identifierPrefix).label")
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
      Capsule()
        .fill(ThemeColor.subtlePanelFill(for: colorScheme))
    )
    .accessibilityIdentifier(identifierPrefix)
  }
}

struct AnimatedSignalDot: View {
  @Environment(\.colorScheme) private var colorScheme
  let isAnimated: Bool
  let identifier: String
  @State private var isExpanded = false

  var body: some View {
    Circle()
      .fill(colorScheme == .dark ? Color.white : ThemeColor.accent)
      .frame(width: 6, height: 6)
      .overlay(
        Circle()
          .stroke(
            (colorScheme == .dark ? Color.white : ThemeColor.accent).opacity(isAnimated ? 0.22 : 0.32),
            lineWidth: 5
          )
          .frame(width: isExpanded ? 20 : 16, height: isExpanded ? 20 : 16)
          .opacity(isExpanded ? 0.25 : 0.65)
      )
      .task(id: isAnimated) {
        guard isAnimated else {
          isExpanded = false
          return
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
          isExpanded = true
        }
      }
      .accessibilityIdentifier(identifier)
  }
}

struct FloatingPanelEffect: ViewModifier {
  let isActive: Bool
  @State private var isFloating = false

  func body(content: Content) -> some View {
    content
      .offset(y: isActive ? (isFloating ? -4 : 4) : 0)
      .task(id: isActive) {
        guard isActive else {
          isFloating = false
          return
        }

        withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
          isFloating = true
        }
      }
  }
}

struct AmbientBreathingEffect: ViewModifier {
  let isActive: Bool
  @State private var isExpanded = false

  func body(content: Content) -> some View {
    content
      .scaleEffect(isExpanded ? 1.015 : 1)
      .task(id: isActive) {
        guard isActive else {
          isExpanded = false
          return
        }

        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
          isExpanded = true
        }
      }
  }
}
