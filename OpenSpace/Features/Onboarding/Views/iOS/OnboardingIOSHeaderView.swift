//
//  OnboardingIOSHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSHeaderView: View {
    // MARK: Internal

    var body: some View {
        ViewThatFits(in: .horizontal) {
            regularHeader
            compactHeader
        }
        .accessibilityIdentifier("onboarding.ios.header")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var regularHeader: some View {
        HStack {
            leadingButton
            Spacer(minLength: 12)
            centerBadge
            Spacer(minLength: 12)
            trailingButton
        }
    }

    private var compactHeader: some View {
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
        Button { } label: {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
                .frame(width: 36, height: 36)
                .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("OpenSpace mark")
        .accessibilityIdentifier("onboarding.ios.header.leading-button")
    }

    private var centerBadge: some View {
        Text("OpenSpace")
            .font(.caption.weight(.semibold))
            .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 0.56)))
            .accessibilityIdentifier("onboarding.ios.header.center-badge")
    }

    private var trailingButton: some View {
        Button { } label: {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
                .frame(width: 36, height: 36)
                .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ambient activity indicator")
        .accessibilityIdentifier("onboarding.ios.header.trailing-button")
    }
}

#Preview("iPhone Header") {
    OnboardingIOSHeaderView()
        .padding(24)
        .onboardingComponentPreviewSurface()
}
