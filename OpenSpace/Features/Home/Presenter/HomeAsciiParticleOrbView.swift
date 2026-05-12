import SwiftUI
import UIKit

private struct ParticleDot {
    let point: CGPoint
    let size: CGFloat
    let opacity: CGFloat
}

private struct ParticleBlock {
    let point: CGPoint
    let glyph: String
    let size: CGFloat
    let opacity: CGFloat
}

private struct ParticleOrbitDotSeed {
    let orbitRadius: CGFloat
    let verticalScale: CGFloat
    let angleOffset: CGFloat
    let radialPulse: CGFloat
    let orbitDuration: CFTimeInterval
    let opacityDuration: CFTimeInterval
    let scaleDuration: CFTimeInterval
    let phaseOffset: CFTimeInterval
    let restOpacity: Float
    let restScale: CGFloat
    let scaleRange: CGFloat
}

private struct ParticleSparkSeed {
    let glyph: String
    let pointSize: CGFloat
    let orbitRadius: CGFloat
    let verticalScale: CGFloat
    let angleOffset: CGFloat
    let radialPulse: CGFloat
    let orbitDuration: CFTimeInterval
    let opacityDuration: CFTimeInterval
    let scaleDuration: CFTimeInterval
    let phaseOffset: CFTimeInterval
    let restOpacity: Float
    let restScale: CGFloat
    let scaleRange: CGFloat
}

private enum ParticleOrbMath {
    nonisolated static func noise(_ value: Double, _ seed: Double) -> Double {
        let mixed = sin(value * 12.9898 + seed * 78.233) * 43758.5453
        return mixed - floor(mixed)
    }

    nonisolated static func gaussian2D(
        x: Double,
        y: Double,
        sigmaX: Double,
        sigmaY: Double
    ) -> Double {
        exp(-0.5 * (pow(x / sigmaX, 2) + pow(y / sigmaY, 2)))
    }
}

