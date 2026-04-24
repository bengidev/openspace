//
//  OnboardingMacHeroSupportViews.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

// MARK: - OnboardingMacCapabilityStrip

struct OnboardingMacCapabilityStrip: View {
    // MARK: Internal

    let chips: [String]
    let hasAppeared: Bool
    let reduceMotion: Bool
    let identifierPrefix: String

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

    // MARK: Private

    private let columns = [
        GridItem(.adaptive(minimum: 84), spacing: 8),
    ]
}

// MARK: - OnboardingMacSessionSurfaceCard

struct OnboardingMacSessionSurfaceCard: View {
    // MARK: Internal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Workspace Surface")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

                Spacer()

                OnboardingMacStatusBadge(title: "LIVE")
            }

            VStack(alignment: .leading, spacing: 8) {
                OnboardingMacSessionRow(icon: "sidebar.leading", title: "Chrome", value: "Pinned navigation and durable context")
                OnboardingMacSessionRow(icon: "square.stack.3d.up", title: "Providers", value: "Code, images, research, and automation")
                OnboardingMacSessionRow(icon: "cpu", title: "Setup", value: "Local AI staging with a calmer first-run path")
            }

            HStack(spacing: 10) {
                OnboardingMacStatTile(value: "2x", label: "denser cues")
                OnboardingMacStatTile(value: "3", label: "desktop panes")
            }
        }
        .padding(14)
        .background(OnboardingMacCardBackground(opacity: 0.12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("onboarding.mac.hero.workspace-card")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacDesktopNotesCard

struct OnboardingMacDesktopNotesCard: View {
    // MARK: Internal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Desktop Notes")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

            desktopMetricStrip

            VStack(alignment: .leading, spacing: 8) {
                OnboardingMacDetailRow(title: "Chrome", value: "Persistent workspace framing")
                OnboardingMacDetailRow(title: "Density", value: "More information per surface")
                OnboardingMacDetailRow(title: "Flow", value: "Desktop-first entry posture")
            }
        }
        .padding(14)
        .background(OnboardingMacCardBackground(opacity: 0.10))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("onboarding.mac.hero.notes-card")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private var desktopMetricStrip: some View {
        HStack(spacing: 8) {
            OnboardingMacCompactMetric(title: "Flow", value: "Focused entry")
                .frame(maxWidth: .infinity, alignment: .leading)

            OnboardingMacCompactMetric(title: "Density", value: "Desktop-first")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - OnboardingMacWorkflowHighlightsCard

struct OnboardingMacWorkflowHighlightsCard: View {
    // MARK: Internal

    let hasAppeared: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Text("Desktop Rhythm")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

                Spacer(minLength: 10)

                OnboardingMacStatusBadge(title: "DESKTOP-FIRST")
            }

            Rectangle()
                .fill(ThemeColor.chromeStroke(for: colorScheme))
                .frame(height: 1)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 8) {
                OnboardingMacDetailRow(title: "Hierarchy", value: "Persistent panels and cues")
                OnboardingMacDetailRow(title: "Setup", value: "Local AI staged in first run")
                OnboardingMacDetailRow(title: "Render", value: "Desktop-aware surface and pacing")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OnboardingMacCardBackground(opacity: 0.10))
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 10)
        .animation(
            .easeOut(duration: 0.75).delay(reduceMotion ? 0 : 0.36),
            value: hasAppeared
        )
        .accessibilityIdentifier("onboarding.mac.hero.workflow-highlights")
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacDetailRow

struct OnboardingMacDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title.uppercased())
                .font(.caption2.monospaced().weight(.medium))
                .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
                .frame(width: 74, alignment: .leading)

            Text(value)
                .font(.footnote)
                .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacSessionRow

private struct OnboardingMacSessionRow: View {
    // MARK: Internal

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
                .frame(width: 26, height: 26)
                .background(Circle().fill(ThemeColor.subtlePanelFill(for: colorScheme)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))

                Text(value)
                    .font(.footnote)
                    .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
            }
        }
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacStatTile

private struct OnboardingMacStatTile: View {
    // MARK: Internal

    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))

            Text(label)
                .font(.caption2)
                .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ThemeColor.subtlePanelFill(for: colorScheme))
        )
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacCompactMetric

private struct OnboardingMacCompactMetric: View {
    // MARK: Internal

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.monospaced().weight(.medium))
                .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
                .lineLimit(1)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(ThemeColor.overlayTextPrimary(for: colorScheme))
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ThemeColor.subtlePanelFill(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(ThemeColor.chromeStroke(for: colorScheme), lineWidth: 1)
                )
        )
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacStatusBadge

private struct OnboardingMacStatusBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.monospaced().weight(.medium))
            .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(ThemeColor.subtlePanelFill(for: colorScheme)))
    }

    @Environment(\.colorScheme) private var colorScheme
}

// MARK: - OnboardingMacCardBackground

private struct OnboardingMacCardBackground: View {
    let opacity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                colorScheme == .dark
                    ? ThemeColor.accent100.opacity(max(opacity * 1.15, 0.08))
                    : ThemeColor.accent100.opacity(max(opacity * 5.2, 0.40))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(ThemeColor.chromeStroke(for: colorScheme), lineWidth: 1)
            )
    }

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("Mac Capability Strip") {
    OnboardingMacCapabilityStrip(
        chips: ["Code", "Images", "Research", "Automation"],
        hasAppeared: true,
        reduceMotion: true,
        identifierPrefix: "preview.onboarding.mac.capabilities"
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 640, height: 180))
}

#Preview("Mac Session Surface Card") {
    OnboardingMacSessionSurfaceCard()
        .padding(24)
        .onboardingPreviewSurface(size: CGSize(width: 520, height: 340))
}

#Preview("Mac Workflow Highlights") {
    OnboardingMacWorkflowHighlightsCard(
        hasAppeared: true,
        reduceMotion: true
    )
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 520, height: 280))
}

#Preview("Desktop Workspace Card") {
    OnboardingMacSessionSurfaceCard()
        .padding(24)
        .onboardingPreviewSurface(size: CGSize(width: 480, height: 260))
}
