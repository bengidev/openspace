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

    static func makeSparkSeeds(seedOffset: Int, count: Int) -> [ParticleSparkSeed] {
        var seeds: [ParticleSparkSeed] = []
        seeds.reserveCapacity(count)

        for index in 0..<count {
            let seed = Double(seedOffset + index)
            let energy = ParticleOrbMath.noise(seed, 7)
            let glyphIndex = min(
                ParticleOrbMetrics.glyphRamp.count - 1,
                max(0, Int((energy * Double(ParticleOrbMetrics.glyphRamp.count)).rounded()) - 1)
            )
            let angleOffset = CGFloat(ParticleOrbMath.noise(seed, 13) * .pi * 2)
            let orbitRadius = CGFloat(34 + ParticleOrbMath.noise(seed, 17) * 76)
            let pointSize = CGFloat(5.2 + ParticleOrbMath.noise(seed, 23) * 4.8)
            let opacity = Float(0.08 + ParticleOrbMath.noise(seed, 29) * 0.18)

            seeds.append(
                ParticleSparkSeed(
                    glyph: ParticleOrbMetrics.glyphRamp[glyphIndex],
                    pointSize: pointSize,
                    orbitRadius: orbitRadius,
                    verticalScale: CGFloat(0.58 + ParticleOrbMath.noise(seed, 31) * 0.26),
                    angleOffset: angleOffset,
                    radialPulse: CGFloat(2 + ParticleOrbMath.noise(seed, 37) * 5),
                    orbitDuration: CFTimeInterval(8.5 + ParticleOrbMath.noise(seed, 41) * 10.0),
                    opacityDuration: CFTimeInterval(5.5 + ParticleOrbMath.noise(seed, 43) * 5.0),
                    scaleDuration: CFTimeInterval(6.0 + ParticleOrbMath.noise(seed, 47) * 5.0),
                    phaseOffset: CFTimeInterval(ParticleOrbMath.noise(seed, 53) * 9.0),
                    restOpacity: opacity,
                    restScale: CGFloat(0.74 + ParticleOrbMath.noise(seed, 59) * 0.34),
                    scaleRange: CGFloat(0.06 + ParticleOrbMath.noise(seed, 61) * 0.10)
                )
            )
        }

        return seeds
    }

    static func makeOuterOrbitDotSeeds(seedOffset: Int, count: Int) -> [ParticleOrbitDotSeed] {
        var seeds: [ParticleOrbitDotSeed] = []
        seeds.reserveCapacity(count)

        for index in 0..<count {
            let seed = Double(seedOffset + index)
            let angleOffset = CGFloat(Double(index) / Double(count) * .pi * 2)
                + CGFloat((ParticleOrbMath.noise(seed, 13) - 0.5) * 0.18)
            let ring = ParticleOrbMath.noise(seed, 17)
            let orbitRadius = CGFloat(94 + ring * 72)
            let opacity = Float(0.07 + ParticleOrbMath.noise(seed, 29) * 0.15)

            seeds.append(
                ParticleOrbitDotSeed(
                    orbitRadius: orbitRadius,
                    verticalScale: CGFloat(0.56 + ParticleOrbMath.noise(seed, 31) * 0.22),
                    angleOffset: angleOffset,
                    radialPulse: CGFloat(1.4 + ParticleOrbMath.noise(seed, 37) * 4.6),
                    orbitDuration: CFTimeInterval(17.0 + ParticleOrbMath.noise(seed, 41) * 14.0),
                    opacityDuration: CFTimeInterval(7.5 + ParticleOrbMath.noise(seed, 43) * 7.0),
                    scaleDuration: CFTimeInterval(8.0 + ParticleOrbMath.noise(seed, 47) * 6.5),
                    phaseOffset: CFTimeInterval(ParticleOrbMath.noise(seed, 53) * 13.0),
                    restOpacity: opacity,
                    restScale: CGFloat(0.34 + ParticleOrbMath.noise(seed, 59) * 0.56),
                    scaleRange: CGFloat(0.035 + ParticleOrbMath.noise(seed, 61) * 0.07)
                )
            )
        }

        return seeds
    }

    static func makeCoreBlocks(seedOffset: Int, count: Int, prominence: Double) -> [ParticleBlock] {
        var blocks: [ParticleBlock] = []
        blocks.reserveCapacity(count)

        let maxAttempts = count * 12
        var attempts = 0

        while blocks.count < count && attempts < maxAttempts {
            let seed = Double(seedOffset + attempts)
            let x = ParticleOrbMath.noise(seed, 3) * 2 - 1
            let y = ParticleOrbMath.noise(seed, 9) * 2 - 1
            let density = coreDensity(x: x, y: y, seed: seed) * prominence

            if ParticleOrbMath.noise(seed, 15) < density {
                let snappedX = snap(
                    ParticleOrbMetrics.center.x + CGFloat(x) * ParticleOrbMetrics.coreField.width * 0.5
                )
                let snappedY = snap(
                    ParticleOrbMetrics.center.y + CGFloat(y) * ParticleOrbMetrics.coreField.height * 0.5
                )
                let energy = min(1, max(0, density + ParticleOrbMath.noise(seed, 25) * 0.12))
                let size = CGFloat(4.1 + energy * 5.8 + ParticleOrbMath.noise(seed, 21) * 1.1)
                let glyphIndex = min(
                    ParticleOrbMetrics.glyphRamp.count - 1,
                    max(0, Int((energy * Double(ParticleOrbMetrics.glyphRamp.count)).rounded()) - 1)
                )
                let opacity = CGFloat(min(1, 0.18 + energy * 0.82 + ParticleOrbMath.noise(seed, 33) * 0.08))

                blocks.append(
                    ParticleBlock(
                        point: CGPoint(x: snappedX, y: snappedY),
                        glyph: ParticleOrbMetrics.glyphRamp[glyphIndex],
                        size: size,
                        opacity: opacity
                    )
                )
            }

            attempts += 1
        }

        return blocks
    }

    static func coreDensity(x: Double, y: Double, seed: Double) -> Double {
        let radius = sqrt(x * x + y * y)
        let angle = atan2(y, x)
        let shell = max(0, 1 - pow(radius / 1.05, 2)) * 0.36
        let ring = exp(-pow((radius - 0.56) / 0.24, 2)) * 0.34
        let centerMass = ParticleOrbMath.gaussian2D(x: x + 0.03, y: y + 0.02, sigmaX: 0.34, sigmaY: 0.30) * 0.38
        let upperLeftMass = ParticleOrbMath.gaussian2D(x: x + 0.24, y: y + 0.15, sigmaX: 0.28, sigmaY: 0.18) * 0.28
        let lowerRightMass = ParticleOrbMath.gaussian2D(x: x - 0.22, y: y - 0.20, sigmaX: 0.22, sigmaY: 0.20) * 0.24
        let spiral = (0.5 + 0.5 * sin(angle * 3.2 + radius * 8.4)) * 0.16
        let centerCut = ParticleOrbMath.gaussian2D(x: x - 0.02, y: y - 0.02, sigmaX: 0.18, sigmaY: 0.16) * 0.20
        let bite = ParticleOrbMath.gaussian2D(x: x + 0.34, y: y - 0.23, sigmaX: 0.18, sigmaY: 0.14) * 0.18
        let noise = (ParticleOrbMath.noise(seed, 41) - 0.5) * 0.20

        return min(1, max(0, shell + ring + centerMass + upperLeftMass + lowerRightMass + spiral - centerCut - bite + noise))
    }

    static func snap(_ value: CGFloat) -> CGFloat {
        (value / ParticleOrbMetrics.snapGrid).rounded() * ParticleOrbMetrics.snapGrid
    }
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

