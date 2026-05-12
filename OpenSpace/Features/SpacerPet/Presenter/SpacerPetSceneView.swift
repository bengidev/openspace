//
//  SpacerPetSceneView.swift
//  OpenSpace
//

import SceneKit
import SwiftUI

struct SpacerPetSceneView: UIViewRepresentable {
    let palette: OpenSpacePalette
    let motion: SpacerPetMotion
    let expression: SpacerPetExpression
    let motionStartedAt: Date
    let loadIdentifier: UUID
    let reduceMotion: Bool

    func makeCoordinator() -> SpacerPetSceneCoordinator {
        SpacerPetSceneCoordinator(loadIdentifier: loadIdentifier)
    }

    func makeUIView(context: Context) -> SCNView {
        context.coordinator.makeView()
    }

    func updateUIView(_ view: SCNView, context: Context) {
        context.coordinator.update(
            palette: palette,
            motion: motion,
            expression: expression,
            motionStartedAt: motionStartedAt,
            reduceMotion: reduceMotion
        )
    }
}
