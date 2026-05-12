//
//  SpacerPetMenuButton.swift
//  OpenSpace
//

import SwiftUI

struct SpacerPetMenuButton: View {
    let title: String
    let systemImage: String
    let isEnabled: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)
            }
            .foregroundStyle(isEnabled ? palette.textPrimary : palette.textMuted.opacity(0.56))
            .frame(minHeight: 36)
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(palette.surface.opacity(isEnabled ? 0.74 : 0.32))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(palette.border.opacity(isEnabled ? 1 : 0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
