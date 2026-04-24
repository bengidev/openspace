//
//  OnboardingMacHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeaderView: View {
    // MARK: Internal

    var body: some View {
        ViewThatFits(in: .horizontal) {
            regularHeader
            compactHeader
        }
        .accessibilityIdentifier("onboarding.mac.header")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var regularHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            identityBlock

            Spacer(minLength: 16)

            HStack(spacing: 8) {
                headerBadge("DESKTOP SURFACE")
                headerBadge("WINDOW READY")
            }
        }
    }

    private var compactHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            identityBlock

            HStack(spacing: 8) {
                headerBadge("DESKTOP SURFACE")
                headerBadge("WINDOW READY")
            }
        }
    }

    private var identityBlock: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
                .frame(width: 34, height: 34)
                .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme)))

            VStack(alignment: .leading, spacing: 4) {
                Text("OpenSpace")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))

                Text("Desktop onboarding for local, multi-tool work")
                    .font(.caption)
                    .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .accessibilityIdentifier("onboarding.mac.header.identity")
    }

    private func headerBadge(_ title: String) -> some View {
        Text(title)
            .font(.caption2.monospaced().weight(.medium))
            .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 0.95)))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .accessibilityIdentifier("onboarding.mac.header.badge.\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}

#Preview("Desktop Header") {
    OnboardingMacHeaderView()
        .padding(24)
        .onboardingPreviewSurface(size: CGSize(width: 1120, height: 120))
}
