//
//  OnboardingIOSCapabilityStripView.swift
//  OpenSpace
//
//  iPhone-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingIOSCapabilityStrip

struct OnboardingIOSCapabilityStrip: View {
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

#Preview("iPhone Onboarding Capability Strip") {
    let context = OnboardingPreviewSupport.context(
        variant: .ios,
        size: CGSize(width: 390, height: 844)
    )
    let layout = OnboardingIOSLayout(context: context)

    OnboardingIOSCapabilityStrip(
        chips: context.capabilityChips,
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        spacing: layout.capabilitySpacing,
        chipPadding: layout.capabilityChipPadding,
        identifierPrefix: "preview.onboarding.ios.capabilities"
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 390, height: 160))
}
