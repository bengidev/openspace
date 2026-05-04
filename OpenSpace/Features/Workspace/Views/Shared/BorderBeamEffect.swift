//
//  BorderBeamEffect.swift
//  OpenSpace
//
//  Imported from OpenMac — adapted for OpenSpace design system.
//

import SwiftUI

extension View {
    @ViewBuilder
    func borderBeam(
        border: Color,
        hideFadeBorder: Bool = true,
        beam: [Color],
        beamBlur: CGFloat,
        cornerRadius: CGFloat,
        isEnabled: Bool = true
    ) -> some View {
        modifier(
            BorderBeamEffect(
                border: border,
                hideFadeBorder: hideFadeBorder,
                beam: beam,
                beamBlur: beamBlur,
                cornerRadius: cornerRadius,
                isEnabled: isEnabled
            )
        )
    }
}

struct BorderBeamEffect: ViewModifier {
    var border: Color
    var hideFadeBorder: Bool
    var beam: [Color]
    var beamBlur: CGFloat
    var cornerRadius: CGFloat
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .background {
                if isEnabled {
                    buildBorderBeamView()
                }
            }
    }

    @ViewBuilder
    private func buildBorderBeamView() -> some View {
        ZStack {
            if !hideFadeBorder {
                /// Optional: faded border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border.tertiary, lineWidth: 0.6)
            }

            /// Using keyframe animator to animate the border beam!
            KeyframeAnimator(initialValue: 0.0, repeating: true) {
                value in
                let rotation = value * 365
                let borderGradient = AngularGradient(
                    colors: [.clear, border, .clear],
                    center: .center,
                    startAngle: .degrees(140 + rotation),
                    endAngle: .degrees(270 + rotation)
                )

                let beamGradient = LinearGradient(
                    colors: beam,
                    startPoint: .topLeading,
                    endPoint: .bottomLeading
                )

                /// Beam gradient
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(beamGradient)
                    /// Inverse masking to show only some limited amount of beam gradient
                    /// Using blur instead of padding, so that we can get smooth ending
                    .mask {
                        Rectangle()
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: cornerRadius
                                )
                                .blur(radius: beamBlur)
                                .blendMode(.destinationOut)
                            }
                    }
                    /// Masking it with already have the border gradient to sync
                    /// with the border effect
                    .mask {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(borderGradient)
                            .blur(radius: beamBlur / 1.5)
                            .padding(-beamBlur * 2)
                    }

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: 0.6)
            } keyframes: { _ in
                LinearKeyframe(1, duration: 2.5)
            }
        }
        .padding(0.5)
    }
}

// MARK: - Overlay Variant

extension View {
    @ViewBuilder
    func borderBeamOverlay(
        border: Color,
        hideFadeBorder: Bool = true,
        beam: [Color],
        beamBlur: CGFloat,
        cornerRadius: CGFloat,
        isEnabled: Bool = true
    ) -> some View {
        modifier(
            BorderBeamOverlayEffect(
                border: border,
                hideFadeBorder: hideFadeBorder,
                beam: beam,
                beamBlur: beamBlur,
                cornerRadius: cornerRadius,
                isEnabled: isEnabled
            )
        )
    }
}

struct BorderBeamOverlayEffect: ViewModifier {
    var border: Color
    var hideFadeBorder: Bool
    var beam: [Color]
    var beamBlur: CGFloat
    var cornerRadius: CGFloat
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isEnabled {
                    buildBorderBeamView()
                }
            }
    }

    @ViewBuilder
    private func buildBorderBeamView() -> some View {
        ZStack {
            if !hideFadeBorder {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border.tertiary, lineWidth: 0.6)
            }

            KeyframeAnimator(initialValue: 0.0, repeating: true) {
                value in
                let rotation = value * 365
                let borderGradient = AngularGradient(
                    colors: [.clear, border, .clear],
                    center: .center,
                    startAngle: .degrees(140 + rotation),
                    endAngle: .degrees(270 + rotation)
                )

                let beamGradient = LinearGradient(
                    colors: beam,
                    startPoint: .topLeading,
                    endPoint: .bottomLeading
                )

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(beamGradient)
                    .mask {
                        Rectangle()
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: cornerRadius
                                )
                                .blur(radius: beamBlur)
                                .blendMode(.destinationOut)
                            }
                    }
                    .mask {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(borderGradient)
                            .blur(radius: beamBlur / 1.5)
                            .padding(-beamBlur * 2)
                    }

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: 0.6)
            } keyframes: { _ in
                LinearKeyframe(1, duration: 2.5)
            }
        }
        .padding(0.5)
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(ThemeColor.panelFill(for: .dark))
        .frame(width: 200, height: 120)
        .borderBeam(
            border: ThemeColor.accent,
            beam: [ThemeColor.accent, ThemeColor.accent100, ThemeColor.accent200],
            beamBlur: 8,
            cornerRadius: 20
        )
        .padding(40)
        .background(ThemeColor.backgroundPrimary)
        .preferredColorScheme(.dark)
}
