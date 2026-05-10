//
//  SpacerPetBody.swift
//  OpenSpace
//

import SwiftUI

struct SpacerPetBody: View {
    let palette: OpenSpacePalette
    let motion: SpacerPetMotion
    let expression: SpacerPetExpression
    let motionStartedAt: Date
    let loadIdentifier: UUID
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 7) {
            FactoryBadge(
                title: motion.title,
                systemImage: motion.systemImage,
                palette: palette
            )

            SpacerPetSceneView(
                palette: palette,
                motion: motion,
                expression: expression,
                motionStartedAt: motionStartedAt,
                loadIdentifier: loadIdentifier,
                reduceMotion: reduceMotion
            )
            .frame(width: 156, height: 156)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: motion)
    }
}
