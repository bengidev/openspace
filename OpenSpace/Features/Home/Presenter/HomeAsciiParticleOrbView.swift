import SwiftUI
import UIKit

private enum ParticleOrbMetrics {
    static let canvasSize = CGSize(width: 360, height: 240)
    static let center = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)
    static let outerField = CGSize(width: 324, height: 204)
    static let coreField = CGSize(width: 156, height: 146)
    static let renderScale = max(UIScreen.main.scale, 2)
    static let snapGrid: CGFloat = 3
    static let glyphRamp = Array("░▒▓█").map(String.init)
}

private enum ParticleOrbLayoutFactory {
    static func makeOuterDots(seedOffset: Int, count: Int, radiusBias: Double) -> [ParticleDot] {
        var dots: [ParticleDot] = []
        dots.reserveCapacity(count)

        for index in 0..<count {
            let seed = Double(seedOffset + index)
            let orbit = 0.28 + pow(ParticleOrbMath.noise(seed, 3), 0.82) * radiusBias
            let angle = ParticleOrbMath.noise(seed, 11) * .pi * 2
            let jitterX = (ParticleOrbMath.noise(seed, 29) - 0.5) * 14
            let jitterY = (ParticleOrbMath.noise(seed, 37) - 0.5) * 11
            let point = CGPoint(
                x: ParticleOrbMetrics.center.x + cos(angle) * ParticleOrbMetrics.outerField.width * CGFloat(orbit) * 0.5 + jitterX,
                y: ParticleOrbMetrics.center.y + sin(angle) * ParticleOrbMetrics.outerField.height * CGFloat(orbit) * 0.5 + jitterY
            )
            let size = CGFloat(1.2 + ParticleOrbMath.noise(seed, 47) * 2.4)
            let opacity = CGFloat(0.16 + ParticleOrbMath.noise(seed, 59) * 0.28)
            dots.append(
                ParticleDot(
                    point: point,
                    size: size,
                    opacity: opacity
                )
            )
        }

        return dots
    }

    static func makeOrbDust(seedOffset: Int, count: Int) -> [ParticleDot] {
        var dots: [ParticleDot] = []
        dots.reserveCapacity(count)

        for index in 0..<count {
            let seed = Double(seedOffset + index)
            let angle = ParticleOrbMath.noise(seed, 5) * .pi * 2
            let radial = 0.18 + pow(ParticleOrbMath.noise(seed, 13), 0.58) * 0.50
            let point = CGPoint(
                x: ParticleOrbMetrics.center.x + cos(angle) * ParticleOrbMetrics.outerField.width * CGFloat(radial) * 0.38,
                y: ParticleOrbMetrics.center.y + sin(angle) * ParticleOrbMetrics.outerField.height * CGFloat(radial) * 0.34
            )
            let size = CGFloat(1.1 + ParticleOrbMath.noise(seed, 23) * 2.0)
            let opacity = CGFloat(0.10 + ParticleOrbMath.noise(seed, 31) * 0.18)

            dots.append(
                ParticleDot(
                    point: point,
                    size: size,
                    opacity: opacity
                )
            )
        }

        return dots
    }

    static func makePulseDots(seedOffset: Int, count: Int) -> [ParticleDot] {
        var dots: [ParticleDot] = []
        dots.reserveCapacity(count)

        for index in 0..<count {
            let seed = Double(seedOffset + index)
            let angle = Double(index) / Double(count) * .pi * 2 + (ParticleOrbMath.noise(seed, 5) - 0.5) * 0.22
            let radius = CGFloat(0.38 + ParticleOrbMath.noise(seed, 13) * 0.16)
            let point = CGPoint(
                x: ParticleOrbMetrics.center.x + cos(angle) * ParticleOrbMetrics.coreField.width * radius,
                y: ParticleOrbMetrics.center.y + sin(angle) * ParticleOrbMetrics.coreField.height * radius * 0.70
            )
            let size = CGFloat(1.0 + ParticleOrbMath.noise(seed, 19) * 2.1)
            let opacity = CGFloat(0.08 + ParticleOrbMath.noise(seed, 31) * 0.22)

            dots.append(ParticleDot(point: point, size: size, opacity: opacity))
        }

        return dots
    }

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

