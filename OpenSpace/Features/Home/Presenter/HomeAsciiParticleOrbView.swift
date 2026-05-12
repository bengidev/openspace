import SwiftUI
import UIKit

struct HomeAsciiParticleOrbView: View {
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private static let darkRasterCache = ParticleOrbRasterCache.make(
        tint: UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
    )
    private static let lightRasterCache = ParticleOrbRasterCache.make(
        tint: UIColor(red: 21 / 255, green: 19 / 255, blue: 15 / 255, alpha: 1)
    )

    private var particleColor: Color {
        palette.isDark ? .white : palette.textPrimary
    }

    private var rasterCache: ParticleOrbRasterCache {
        palette.isDark ? Self.darkRasterCache : Self.lightRasterCache
    }

    private var shouldAnimate: Bool {
        reduceMotion == false && scenePhase == .active
    }

    @ViewBuilder
    var body: some View {
        if shouldAnimate {
            TimelineView(.periodic(from: .now, by: ParticleOrbConfig.frameInterval)) { timeline in
                particleCanvas(phase: timeline.date.timeIntervalSinceReferenceDate)
            }
        } else {
            particleCanvas(phase: 1.4)
        }
    }

    private func particleCanvas(phase: Double) -> some View {
        Canvas(rendersAsynchronously: true) { context, size in
            let field = min(size.width, size.height) * 0.82
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

            drawHaloLayers(
                rasterCache.haloInstances,
                in: context,
                center: center,
                field: field,
                phase: phase
            )
            drawCoreLayers(
                rasterCache.coreInstances,
                in: context,
                center: center,
                field: field,
                phase: phase
            )
            drawBreathingCenter(in: context, center: center, field: field, phase: phase)
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func drawHaloLayers(
        _ instances: [ParticleOrbRasterLayerInstance],
        in context: GraphicsContext,
        center: CGPoint,
        field: CGFloat,
        phase: Double
    ) {
        for instance in instances {
            drawRasterLayer(
                instance,
                in: context,
                center: center,
                field: field,
                phase: phase,
                scaleMultiplier: 1
            )
        }
    }

    private func drawCoreLayers(
        _ instances: [ParticleOrbRasterLayerInstance],
        in context: GraphicsContext,
        center: CGPoint,
        field: CGFloat,
        phase: Double
    ) {
        for instance in instances {
            drawRasterLayer(
                instance,
                in: context,
                center: center,
                field: field,
                phase: phase,
                scaleMultiplier: 1
            )
        }
    }

    private func drawRasterLayer(
        _ instance: ParticleOrbRasterLayerInstance,
        in context: GraphicsContext,
        center: CGPoint,
        field: CGFloat,
        phase: Double,
        scaleMultiplier: CGFloat
    ) {
        let rotation = phase * instance.angularVelocity
            + sin(phase * instance.wobbleVelocity + instance.phaseOffset) * instance.wobbleAmplitude
        let scale = field / ParticleOrbConfig.baseField
            * (instance.scaleBase + CGFloat(sin(phase * instance.scaleVelocity + instance.phaseOffset)) * instance.scaleAmplitude)
            * scaleMultiplier
        let opacity = max(
            0,
            min(
                1,
                instance.opacityBase + sin(phase * instance.opacityVelocity + instance.phaseOffset) * instance.opacityAmplitude
            )
        )
        let rect = CGRect(
            x: -ParticleOrbConfig.rasterCanvasSize.width * 0.5,
            y: -ParticleOrbConfig.rasterCanvasSize.height * 0.5,
            width: ParticleOrbConfig.rasterCanvasSize.width,
            height: ParticleOrbConfig.rasterCanvasSize.height
        )

        var layerContext = context
        layerContext.translateBy(x: center.x, y: center.y)
        layerContext.rotate(by: .radians(rotation))
        layerContext.scaleBy(x: scale, y: scale)
        layerContext.opacity = opacity
        let resolvedImage = layerContext.resolve(instance.image)
        layerContext.draw(resolvedImage, in: rect)
    }

    private func drawBreathingCenter(in context: GraphicsContext, center: CGPoint, field: CGFloat, phase: Double) {
        let pulse = 0.5 + 0.5 * sin(phase * 1.05)

        for ring in 0..<3 {
            let progress = (pulse + Double(ring) * 0.28).truncatingRemainder(dividingBy: 1)
            let radius = field * (0.055 + progress * 0.16)
            let opacity = pow(1 - progress, 1.7) * 0.10
            let rect = CGRect(
                x: center.x - radius,
                y: center.y - radius * 0.78,
                width: radius * 2,
                height: radius * 1.56
            )

            context.stroke(
                Path(ellipseIn: rect),
                with: .color(particleColor.opacity(opacity)),
                lineWidth: 0.8
            )
        }
    }
}

private enum ParticleOrbConfig {
    static let frameInterval = 1.0 / 36.0
    static let coreParticleCount = 540
    static let haloParticleCount = 320
    static let baseField: CGFloat = 160
    static let rasterCanvasSize = CGSize(width: 360, height: 360)
    static let rasterScale: CGFloat = 2
    static let glyphRamp = Array("░▒▓█").map(String.init)
}

private struct ParticleOrbRasterCache {
    let haloInstances: [ParticleOrbRasterLayerInstance]
    let coreInstances: [ParticleOrbRasterLayerInstance]

    static func make(tint: UIColor) -> Self {
        let haloImages = ParticleOrbRenderer.makeHaloImages(tint: tint)
        let coreImages = ParticleOrbRenderer.makeCoreImages(tint: tint)

        return Self(
            haloInstances: [
                ParticleOrbRasterLayerInstance(
                    image: haloImages[0],
                    angularVelocity: 0.08,
                    wobbleAmplitude: 0.04,
                    wobbleVelocity: 0.26,
                    scaleBase: 1.00,
                    scaleAmplitude: 0.02,
                    scaleVelocity: 0.44,
                    opacityBase: 0.34,
                    opacityAmplitude: 0.08,
                    opacityVelocity: 0.62,
                    phaseOffset: 0.0
                ),
                ParticleOrbRasterLayerInstance(
                    image: haloImages[0],
                    angularVelocity: -0.05,
                    wobbleAmplitude: 0.03,
                    wobbleVelocity: 0.33,
                    scaleBase: 0.97,
                    scaleAmplitude: 0.015,
                    scaleVelocity: 0.50,
                    opacityBase: 0.20,
                    opacityAmplitude: 0.05,
                    opacityVelocity: 0.80,
                    phaseOffset: 1.7
                ),
                ParticleOrbRasterLayerInstance(
                    image: haloImages[1],
                    angularVelocity: 0.11,
                    wobbleAmplitude: 0.05,
                    wobbleVelocity: 0.29,
                    scaleBase: 1.03,
                    scaleAmplitude: 0.025,
                    scaleVelocity: 0.38,
                    opacityBase: 0.28,
                    opacityAmplitude: 0.06,
                    opacityVelocity: 0.68,
                    phaseOffset: 2.4
                ),
                ParticleOrbRasterLayerInstance(
                    image: haloImages[1],
                    angularVelocity: -0.07,
                    wobbleAmplitude: 0.025,
                    wobbleVelocity: 0.41,
                    scaleBase: 0.94,
                    scaleAmplitude: 0.018,
                    scaleVelocity: 0.56,
                    opacityBase: 0.16,
                    opacityAmplitude: 0.04,
                    opacityVelocity: 0.74,
                    phaseOffset: 4.2
                )
            ],
            coreInstances: [
                ParticleOrbRasterLayerInstance(
                    image: coreImages[0],
                    angularVelocity: 0.48,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 0.98,
                    scaleAmplitude: 0.018,
                    scaleVelocity: 0.92,
                    opacityBase: 0.72,
                    opacityAmplitude: 0.10,
                    opacityVelocity: 0.84,
                    phaseOffset: 0.0
                ),
                ParticleOrbRasterLayerInstance(
                    image: coreImages[0],
                    angularVelocity: 0.71,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 1.01,
                    scaleAmplitude: 0.020,
                    scaleVelocity: 1.14,
                    opacityBase: 0.30,
                    opacityAmplitude: 0.08,
                    opacityVelocity: 1.20,
                    phaseOffset: 1.1
                ),
                ParticleOrbRasterLayerInstance(
                    image: coreImages[1],
                    angularVelocity: 0.44,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 0.99,
                    scaleAmplitude: 0.015,
                    scaleVelocity: 0.88,
                    opacityBase: 0.70,
                    opacityAmplitude: 0.10,
                    opacityVelocity: 0.78,
                    phaseOffset: 0.9
                ),
                ParticleOrbRasterLayerInstance(
                    image: coreImages[1],
                    angularVelocity: 0.66,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 1.02,
                    scaleAmplitude: 0.018,
                    scaleVelocity: 1.06,
                    opacityBase: 0.28,
                    opacityAmplitude: 0.07,
                    opacityVelocity: 1.12,
                    phaseOffset: 2.8
                ),
                ParticleOrbRasterLayerInstance(
                    image: coreImages[2],
                    angularVelocity: 0.40,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 1.00,
                    scaleAmplitude: 0.015,
                    scaleVelocity: 0.95,
                    opacityBase: 0.68,
                    opacityAmplitude: 0.09,
                    opacityVelocity: 0.90,
                    phaseOffset: 1.8
                ),
                ParticleOrbRasterLayerInstance(
                    image: coreImages[2],
                    angularVelocity: 0.63,
                    wobbleAmplitude: 0,
                    wobbleVelocity: 1,
                    scaleBase: 1.03,
                    scaleAmplitude: 0.017,
                    scaleVelocity: 1.18,
                    opacityBase: 0.27,
                    opacityAmplitude: 0.06,
                    opacityVelocity: 1.26,
                    phaseOffset: 3.6
                )
            ]
        )
    }
}

private struct ParticleOrbRasterLayerInstance {
    let image: Image
    let angularVelocity: Double
    let wobbleAmplitude: Double
    let wobbleVelocity: Double
    let scaleBase: CGFloat
    let scaleAmplitude: CGFloat
    let scaleVelocity: Double
    let opacityBase: Double
    let opacityAmplitude: Double
    let opacityVelocity: Double
    let phaseOffset: Double
}

private enum ParticleOrbRenderer {
    static func makeHaloImages(tint: UIColor) -> [Image] {
        ParticleOrbLayoutFactory.makeHaloLayers().map { particles in
            renderImage { context in
                for particle in particles {
                    context.setFillColor(tint.withAlphaComponent(particle.opacity).cgColor)
                    let rect = CGRect(
                        x: particle.point.x - particle.size * 0.5,
                        y: particle.point.y - particle.size * 0.5,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fillEllipse(in: rect)
                }
            }
        }
    }

    static func makeCoreImages(tint: UIColor) -> [Image] {
        let renderer = UIGraphicsImageRenderer(
            size: ParticleOrbConfig.rasterCanvasSize,
            format: rendererFormat()
        )

        return ParticleOrbLayoutFactory.makeCoreLayers().map { particles in
            let uiImage = renderer.image { _ in
                for particle in particles {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.monospacedSystemFont(ofSize: particle.size, weight: .regular),
                        .foregroundColor: tint.withAlphaComponent(particle.opacity)
                    ]
                    let string = NSAttributedString(string: particle.glyph, attributes: attributes)
                    let size = string.size()
                    let origin = CGPoint(
                        x: particle.point.x - size.width * 0.5,
                        y: particle.point.y - size.height * 0.5
                    )
                    string.draw(at: origin)
                }
            }

            return Image(decorative: uiImage.cgImage!, scale: ParticleOrbConfig.rasterScale)
        }
    }

    static func renderImage(_ draw: (CGContext) -> Void) -> Image {
        let renderer = UIGraphicsImageRenderer(
            size: ParticleOrbConfig.rasterCanvasSize,
            format: rendererFormat()
        )
        let uiImage = renderer.image { renderContext in
            draw(renderContext.cgContext)
        }

        return Image(decorative: uiImage.cgImage!, scale: ParticleOrbConfig.rasterScale)
    }

    static func rendererFormat() -> UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        format.scale = ParticleOrbConfig.rasterScale
        return format
    }
}

private enum ParticleOrbLayoutFactory {
    static func makeHaloLayers() -> [[RasterDot]] {
        var layers = Array(repeating: [RasterDot](), count: 2)
        let center = CGPoint(
            x: ParticleOrbConfig.rasterCanvasSize.width * 0.5,
            y: ParticleOrbConfig.rasterCanvasSize.height * 0.5
        )

        for index in 0..<ParticleOrbConfig.haloParticleCount {
            let seed = Double(index)
            let radiusSeed = ParticleOrbMath.noise(seed, 7)
            let radius = ParticleOrbConfig.baseField * CGFloat(0.34 + radiusSeed * 0.47)
            let angle = ParticleOrbMath.noise(seed, 19) * .pi * 2
            let point = point(center: center, radius: radius, angle: angle, verticalScale: 0.82)
            let shell = 1 - abs(radiusSeed - 0.62)
            let size = CGFloat(0.8 + ParticleOrbMath.noise(seed, 41) * 1.9)
            let opacity = CGFloat(min(0.34, 0.06 + shell * 0.18 + ParticleOrbMath.noise(seed, 53) * 0.08))
            let layerIndex = index % layers.count

            layers[layerIndex].append(
                RasterDot(point: point, size: size, opacity: opacity)
            )
        }

        return layers
    }

    static func makeCoreLayers() -> [[RasterGlyph]] {
        var layers = Array(repeating: [RasterGlyph](), count: 3)
        let center = CGPoint(
            x: ParticleOrbConfig.rasterCanvasSize.width * 0.5,
            y: ParticleOrbConfig.rasterCanvasSize.height * 0.5
        )

        for index in 0..<ParticleOrbConfig.coreParticleCount {
            let seed = Double(index)
            let arm = index % layers.count
            let armAngle = Double(arm) / Double(layers.count) * .pi * 2
            let radialSeed = ParticleOrbMath.noise(seed, 3)
            let radiusFactor = 0.035 + pow(radialSeed, 0.62) * 0.34
            let radius = ParticleOrbConfig.baseField * CGFloat(radiusFactor)
            let angle = armAngle
                + ParticleOrbMath.noise(seed, 13) * .pi * 0.7
                + radiusFactor * .pi * 4.2
            let point = point(center: center, radius: radius, angle: angle, verticalScale: 0.74)
            let centerEnergy = ParticleOrbMath.gaussian(radiusFactor, spread: 0.20)
            let ringEnergy = ParticleOrbMath.gaussian(radiusFactor - 0.27, spread: 0.14)
            let brightness = min(1, 0.22 + centerEnergy * 0.56 + ringEnergy * 0.22 + ParticleOrbMath.noise(seed, 61) * 0.18)
            let glyphIndex = min(
                ParticleOrbConfig.glyphRamp.count - 1,
                max(0, Int((brightness * Double(ParticleOrbConfig.glyphRamp.count - 1)).rounded()))
            )
            let size = CGFloat(3.9 + brightness * 3.8 + ParticleOrbMath.noise(seed, 71) * 0.8)
            let opacity = CGFloat(min(0.96, 0.22 + brightness * 0.64))

            layers[arm].append(
                RasterGlyph(
                    point: point,
                    glyph: ParticleOrbConfig.glyphRamp[glyphIndex],
                    size: size,
                    opacity: opacity
                )
            )
        }

        return layers
    }

    static func point(center: CGPoint, radius: CGFloat, angle: Double, verticalScale: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius * verticalScale
        )
    }
}

private struct RasterDot {
    let point: CGPoint
    let size: CGFloat
    let opacity: CGFloat
}

private struct RasterGlyph {
    let point: CGPoint
    let glyph: String
    let size: CGFloat
    let opacity: CGFloat
}

private enum ParticleOrbMath {
    nonisolated static func gaussian(_ value: Double, spread: Double) -> Double {
        exp(-pow(value / spread, 2))
    }

    nonisolated static func noise(_ value: Double, _ seed: Double) -> Double {
        let mixed = sin(value * 12.9898 + seed * 78.233) * 43758.5453
        return mixed - floor(mixed)
    }
}

#Preview {
    ZStack {
        OpenSpacePalette.resolve(.dark).background.ignoresSafeArea()
        HomeAsciiParticleOrbView()
            .frame(height: 210)
            .padding(.horizontal, 28)
            .environment(\.palette, OpenSpacePalette.resolve(.dark))
    }
}
