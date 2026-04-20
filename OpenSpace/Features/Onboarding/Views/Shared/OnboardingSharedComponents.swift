//
//  OnboardingSharedComponents.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingPlatformPanel<Content: View>: View {
  let variant: OnboardingPlatformVariant
  let context: OnboardingRenderContext
  @ViewBuilder let content: Content

  init(
    variant: OnboardingPlatformVariant,
    context: OnboardingRenderContext,
    @ViewBuilder content: () -> Content
  ) {
    self.variant = variant
    self.context = context
    self.content = content()
  }

  var body: some View {
    OnboardingHeroPanel(
      style: variant.panelStyle,
      cornerRadius: variant.panelCornerRadius
    ) {
      content
        .frame(minHeight: variant.panelMinHeight)
    }
    .frame(maxWidth: variant.panelMaxWidth)
    .padding(.horizontal, variant.panelHorizontalPadding)
    .opacity(context.hasAppeared ? 1 : 0)
    .offset(y: context.hasAppeared ? 0 : 26)
    .scaleEffect(context.reduceMotion ? 1 : (context.hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.9), value: context.hasAppeared)
    .modifier(
      FloatingPanelEffect(
        isActive: context.isAnimated && variant.usesFloatingPanelEffect
      )
    )
  }
}

struct OnboardingHeaderChromeView: View {
  let centerText: String
  let badgeOpacity: Double
  let buttonSize: CGFloat

  init(
    centerText: String,
    badgeOpacity: Double = 0.56,
    buttonSize: CGFloat = 36
  ) {
    self.centerText = centerText
    self.badgeOpacity = badgeOpacity
    self.buttonSize = buttonSize
  }

  var body: some View {
    HStack {
      Button {} label: {
        Image(systemName: "plus")
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(Color(red: 0.05, green: 0.11, blue: 0.13))
          .frame(width: buttonSize, height: buttonSize)
          .background(Circle().fill(Color.white.opacity(0.62)))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("OpenSpace mark")

      Spacer()

      Text(centerText)
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(badgeOpacity)))

      Spacer()

      Button {} label: {
        Image(systemName: "waveform.path.ecg")
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(Color(red: 0.05, green: 0.11, blue: 0.13))
          .frame(width: buttonSize, height: buttonSize)
          .background(Circle().fill(Color.white.opacity(0.62)))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Ambient activity indicator")
    }
  }
}

struct OnboardingHorizontalCapabilityStrip: View {
  let chips: [String]
  let hasAppeared: Bool
  let reduceMotion: Bool
  let spacing: CGFloat
  let chipPadding: CGFloat

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: spacing) {
        ForEach(Array(chips.enumerated()), id: \.element) { index, chip in
          OnboardingCapabilityChip(
            title: chip,
            isVisible: hasAppeared,
            reduceMotion: reduceMotion,
            delay: Double(index) * 0.08,
            horizontalPadding: chipPadding
          )
        }
      }
    }
    .scrollClipDisabled()
  }
}

struct OnboardingMacCapabilityStrip: View {
  let chips: [String]
  let hasAppeared: Bool
  let reduceMotion: Bool

  private let columns = [
    GridItem(.adaptive(minimum: 110), spacing: 10),
  ]

  var body: some View {
    LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
      ForEach(Array(chips.enumerated()), id: \.element) { index, chip in
        OnboardingCapabilityChip(
          title: chip,
          isVisible: hasAppeared,
          reduceMotion: reduceMotion,
          delay: Double(index) * 0.06,
          horizontalPadding: 12
        )
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct OnboardingPrimaryButton: View {
  let title: String
  let hasAppeared: Bool
  let reduceMotion: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color(red: 0.06, green: 0.12, blue: 0.14))
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
          Capsule()
            .fill(Color.white)
        )
    }
    .buttonStyle(.plain)
    .accessibilityHint("Finish onboarding and enter the current app shell")
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.94))
    .opacity(hasAppeared ? 1 : 0)
    .shadow(
      color: Color.white.opacity(reduceMotion ? 0.08 : 0.16),
      radius: hasAppeared ? 14 : 0,
      x: 0,
      y: 6
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
  let labels: [String]
  let hasAppeared: Bool
  let alignment: Alignment

  var body: some View {
    HStack {
      ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
        if index > 0 {
          Spacer(minLength: 12)
        }

        Text(label)
      }
    }
    .frame(maxWidth: .infinity, alignment: alignment)
    .font(.caption2.monospaced())
    .foregroundStyle(Color.white.opacity(0.32))
    .opacity(hasAppeared ? 1 : 0)
    .animation(
      .easeOut(duration: 0.8).delay(0.48),
      value: hasAppeared
    )
  }
}

struct OnboardingSupportingNote: View {
  let text: String
  let hasAppeared: Bool
  let alignment: TextAlignment
  let maxWidth: CGFloat

  var body: some View {
    Text(text)
      .font(.footnote)
      .foregroundStyle(Color.white.opacity(0.56))
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
  let title: String
  let isVisible: Bool
  let reduceMotion: Bool
  let delay: Double
  let horizontalPadding: CGFloat

  var body: some View {
    Text(title)
      .font(.caption)
      .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19))
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(Color.white.opacity(0.56))
      )
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 10)
      .scaleEffect(reduceMotion ? 1 : (isVisible ? 1 : 0.96))
      .animation(
        .easeOut(duration: 0.55).delay(reduceMotion ? 0 : delay),
        value: isVisible
      )
  }
}

struct OnboardingSignalPill: View {
  let isAnimated: Bool
  let label: String

  init(
    isAnimated: Bool,
    label: String = "One workspace for coding, image generation, and local AI setup"
  ) {
    self.isAnimated = isAnimated
    self.label = label
  }

  var body: some View {
    HStack(spacing: 8) {
      AnimatedSignalDot(isAnimated: isAnimated)

      Text(label)
        .font(.caption)
        .foregroundStyle(Color.white.opacity(0.75))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
      Capsule()
        .fill(Color.white.opacity(0.08))
    )
    .overlay(
      Capsule()
        .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.8)
    )
  }
}

struct AnimatedSignalDot: View {
  let isAnimated: Bool
  @State private var isExpanded = false

  var body: some View {
    Circle()
      .fill(Color.white)
      .frame(width: 6, height: 6)
      .overlay(
        Circle()
          .stroke(Color.white.opacity(isAnimated ? 0.22 : 0.32), lineWidth: 5)
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
