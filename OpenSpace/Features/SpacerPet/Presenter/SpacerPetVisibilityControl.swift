//
//  SpacerPetVisibilityControl.swift
//  OpenSpace
//

import SwiftUI

struct SpacerPetVisibilityControl: View {
    let loadingPhase: SpacerPetLoadingPhase
    let isCompanionVisible: Bool
    let canToggle: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    private var buttonTitle: String {
        if isCompanionVisible {
            return "Hide pet"
        }

        return loadingPhase == .ready ? "Show pet" : "Preparing..."
    }

    private var buttonImage: String {
        isCompanionVisible ? "eye.slash.fill" : "eye.fill"
    }

    private var statusTitle: String {
        if loadingPhase == .ready, isCompanionVisible {
            return "Pet is live"
        }

        return loadingPhase.detail
    }

    var body: some View {
        HStack(spacing: 10) {
            statusIndicator

            VStack(alignment: .leading, spacing: 2) {
                Text(loadingPhase.title)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)

                Text(statusTitle)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)

            Button(action: action) {
                HStack(spacing: 6) {
                    Image(systemName: buttonImage)
                        .font(.system(size: 10, weight: .bold))

                    Text(buttonTitle)
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .foregroundStyle(canToggle ? palette.primaryActionText : palette.textMuted.opacity(0.62))
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(
                    Capsule(style: .continuous)
                        .fill(canToggle ? palette.primaryActionFill : palette.surface.opacity(0.72))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(canToggle ? Color.clear : palette.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!canToggle)
            .accessibilityLabel(buttonTitle)
            .accessibilityValue(statusTitle)
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(palette.elevatedSurface.opacity(palette.isDark ? 0.92 : 0.96))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(palette.strongBorder.opacity(0.82), lineWidth: 1)
        )
        .shadow(color: .black.opacity(palette.isDark ? 0.34 : 0.12), radius: 14, y: 8)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        ZStack {
            Circle()
                .fill(loadingPhase == .ready ? palette.success.opacity(0.18) : palette.warning.opacity(0.16))
                .frame(width: 28, height: 28)

            if loadingPhase == .ready {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(palette.success)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .tint(palette.accent)
            }
        }
    }
}
