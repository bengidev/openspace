//
//  OnboardingSignalAndEffectViews.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

// MARK: - OnboardingCapabilityChip

struct OnboardingCapabilityChip: View {
    // MARK: Internal

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

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingSignalPill

struct OnboardingSignalPill: View {
    // MARK: Lifecycle

    init(
        isAnimated: Bool,
        label: String = "One workspace for coding, image generation, and local AI setup",
        identifierPrefix: String = "onboarding.signal-pill"
    ) {
        self.isAnimated = isAnimated
        self.label = label
        self.identifierPrefix = identifierPrefix
    }

    // MARK: Internal

    let isAnimated: Bool
    let label: String
    let identifierPrefix: String

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

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - AnimatedSignalDot

struct AnimatedSignalDot: View {
    // MARK: Internal

    let isAnimated: Bool
    let identifier: String

    var body: some View {
        Circle()
            .fill(ThemeColor.accentHighlight(for: colorScheme))
            .frame(width: 6, height: 6)
            .overlay(
                Circle()
                    .stroke(
                        ThemeColor.accentHighlight(for: colorScheme).opacity(isAnimated ? 0.22 : 0.32),
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

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
}

// MARK: - FloatingPanelEffect

struct FloatingPanelEffect: ViewModifier {
    let isActive: Bool

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

    @State private var isFloating = false
}

// MARK: - AmbientBreathingEffect

struct AmbientBreathingEffect: ViewModifier {
    let isActive: Bool

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

    @State private var isExpanded = false
}

#Preview("Onboarding Signal Pill") {
    OnboardingSignalPill(
        isAnimated: false,
        label: "A broader canvas for code, images, and local AI setup",
        identifierPrefix: "preview.onboarding.signal"
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 520, height: 180))
}

#Preview("Onboarding Capability Chips") {
    HStack(spacing: 8) {
        OnboardingCapabilityChip(
            title: "Code",
            isVisible: true,
            reduceMotion: true,
            delay: 0,
            horizontalPadding: 10,
            identifier: "preview.onboarding.chip.code"
        )

        OnboardingCapabilityChip(
            title: "Images",
            isVisible: true,
            reduceMotion: true,
            delay: 0,
            horizontalPadding: 10,
            identifier: "preview.onboarding.chip.images"
        )

        OnboardingCapabilityChip(
            title: "Research",
            isVisible: true,
            reduceMotion: true,
            delay: 0,
            horizontalPadding: 10,
            identifier: "preview.onboarding.chip.research"
        )
    }
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 520, height: 180))
}
