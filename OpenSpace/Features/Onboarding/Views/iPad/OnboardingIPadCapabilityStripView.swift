//
//  OnboardingIPadCapabilityStripView.swift
//  OpenSpace
//
//  iPad-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingIPadCapabilityStrip

struct OnboardingIPadCapabilityStrip: View {
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

#Preview("iPad Onboarding Capability Strip") {
    let context = OnboardingPreviewSupport.context(
        variant: .ipad,
        size: CGSize(width: 1024, height: 820)
    )
    let layout = OnboardingIPadLayout(context: context)

    OnboardingIPadCapabilityStrip(
        chips: context.capabilityChips,
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        spacing: layout.capabilitySpacing,
        chipPadding: layout.capabilityChipPadding,
        identifierPrefix: "preview.onboarding.ipad.capabilities"
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 840, height: 160))
}
