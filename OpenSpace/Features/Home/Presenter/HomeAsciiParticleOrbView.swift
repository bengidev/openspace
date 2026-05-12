import SwiftUI
import UIKit

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

