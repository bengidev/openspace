import Foundation
import SwiftUI

struct OpenSpaceOnboardingPalette {
    let isDark: Bool
    let background: Color
    let backgroundSecondary: Color
    let surface: Color
    let elevatedSurface: Color
    let inverseSurface: Color
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let border: Color
    let strongBorder: Color
    let accent: Color
    let accentSoft: Color
    let accentText: Color
    let success: Color
    let warning: Color
    let primaryActionFill: Color
    let primaryActionText: Color

    static func resolve(_ scheme: ColorScheme) -> OpenSpaceOnboardingPalette {
        if scheme == .dark {
            return OpenSpaceOnboardingPalette(
                isDark: true,
                background: Color(hex: "020202"),
                backgroundSecondary: Color(hex: "101010"),
                surface: Color(hex: "0a0a0a"),
                elevatedSurface: Color(hex: "161616"),
                inverseSurface: Color(hex: "eeeeee"),
                textPrimary: Color(hex: "eeeeee"),
                textSecondary: Color(hex: "a49d9a"),
                textMuted: Color(hex: "8a8380"),
                border: Color(hex: "3d3a39"),
                strongBorder: Color(hex: "4d4947"),
                accent: Color(hex: "ef6f2e"),
                accentSoft: Color(hex: "ee6018"),
                accentText: Color(hex: "ffffff"),
                success: Color(hex: "8cffb3"),
                warning: Color(hex: "ffcc7a"),
                primaryActionFill: Color(hex: "eeeeee"),
                primaryActionText: Color(hex: "020202")
            )
        }

        return OpenSpaceOnboardingPalette(
            isDark: false,
            background: Color(hex: "fafafa"),
            backgroundSecondary: Color(hex: "eeeeee"),
            surface: Color(hex: "ffffff"),
            elevatedSurface: Color(hex: "f5f5f5"),
            inverseSurface: Color(hex: "15130f"),
            textPrimary: Color(hex: "15130f"),
            textSecondary: Color(hex: "5e594f"),
            textMuted: Color(hex: "8c8577"),
            border: Color(hex: "d8d0c1"),
            strongBorder: Color(hex: "b8b3b0"),
            accent: Color(hex: "d15010"),
            accentSoft: Color(hex: "b74816"),
            accentText: Color(hex: "ffffff"),
            success: Color(hex: "137a42"),
            warning: Color(hex: "a15b08"),
            primaryActionFill: Color(hex: "15130f"),
            primaryActionText: Color(hex: "fafafa")
        )
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch sanitized.count {
        case 3:
            red = ((value >> 8) & 0xF) * 17
            green = ((value >> 4) & 0xF) * 17
            blue = (value & 0xF) * 17
            alpha = 255

        case 6:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 255

        case 8:
            red = (value >> 24) & 0xFF
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF

        default:
            red = 255
            green = 255
            blue = 255
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

struct FactoryBadge: View {
    let title: String
    var systemImage: String? = nil
    let palette: OpenSpaceOnboardingPalette

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(palette.accent)
                .frame(width: 5, height: 5)

            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .semibold))
            }

            Text(title.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(-0.24)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .foregroundStyle(palette.textMuted)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(palette.surface.opacity(0.5))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
    }
}

struct FactoryPrimaryButtonStyle: ButtonStyle {
    let palette: OpenSpaceOnboardingPalette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(palette.primaryActionText)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(palette.primaryActionFill.opacity(configuration.isPressed ? 0.9 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct FactorySecondaryButtonStyle: ButtonStyle {
    let palette: OpenSpaceOnboardingPalette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(palette.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(palette.surface.opacity(configuration.isPressed ? 0.25 : 0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct FactoryCardChrome<Content: View>: View {
    let palette: OpenSpaceOnboardingPalette
    var cornerRadius: CGFloat = 6
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(palette.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct PixelGridBackground: View {
    let palette: OpenSpaceOnboardingPalette
    var spacing: CGFloat = 20
    var dotSize: CGFloat = 1.0
    var opacity = 0.06

    var body: some View {
        Canvas { context, size in
            for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
                for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(palette.textPrimary.opacity(opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct DiagonalHatchPattern: View {
    let palette: OpenSpaceOnboardingPalette
    var spacing: CGFloat = 10
    var opacity = 0.025

    var body: some View {
        Canvas { context, size in
            for x in stride(from: -size.height, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                context.stroke(path, with: .color(palette.textPrimary.opacity(opacity)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

struct FactorySignalGlitchModifier: ViewModifier {
    let progress: Double
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.06 * intensity),
                                Color.clear,
                                Color.blue.opacity(0.06 * intensity),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            .offset(x: sin(progress * .pi * 4) * 0.5 * intensity)
    }
}

extension View {
    func factorySignalGlitch(progress: Double, intensity: Double = 1) -> some View {
        modifier(FactorySignalGlitchModifier(progress: progress, intensity: intensity))
    }
}
