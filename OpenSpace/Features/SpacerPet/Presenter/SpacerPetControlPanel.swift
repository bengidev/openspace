//
//  SpacerPetControlPanel.swift
//  OpenSpace
//

import SwiftUI

struct SpacerPetControlPanel: View {
    let canGrow: Bool
    let canShrink: Bool
    let growAction: () -> Void
    let shrinkAction: () -> Void
    let resetSizeAction: () -> Void
    let playAction: (SpacerPetMotion) -> Void

    @Environment(\.palette) private var palette

    private let motions: [SpacerPetMotion] = [
        .jump,
        .wave,
        .highFive,
        .spin,
        .happyDance,
        .scan,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pet companion")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textMuted)
                .padding(.horizontal, 2)

            HStack(spacing: 8) {
                SpacerPetMenuButton(
                    title: "Make me bigger",
                    systemImage: "plus.magnifyingglass",
                    isEnabled: canGrow,
                    action: growAction
                )

                SpacerPetMenuButton(
                    title: "Make me smaller",
                    systemImage: "minus.magnifyingglass",
                    isEnabled: canShrink,
                    action: shrinkAction
                )
            }

            SpacerPetMenuButton(
                title: "Back to normal",
                systemImage: "arrow.counterclockwise",
                isEnabled: true,
                action: resetSizeAction
            )

            Divider()
                .overlay(palette.border)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(motions, id: \.self) { motion in
                    SpacerPetMenuButton(
                        title: motion.menuTitle,
                        systemImage: motion.systemImage,
                        isEnabled: true,
                        action: {
                            playAction(motion)
                        }
                    )
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(palette.elevatedSurface.opacity(palette.isDark ? 0.94 : 0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(palette.strongBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(palette.isDark ? 0.38 : 0.16), radius: 18, y: 10)
        .accessibilityElement(children: .contain)
    }
}
