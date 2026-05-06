import SwiftUI

// MARK: - TerminalColorScheme (Monochrome)

struct TerminalColorScheme {
    let isDark: Bool

    init(colorScheme: ColorScheme) {
        isDark = colorScheme == .dark
    }

    // MARK: Base Surface

    var background: Color {
        isDark ? Color(hex: "0A0A0A") : Color(hex: "FAFAFA")
    }

    var backgroundElevated: Color {
        isDark ? Color(hex: "141414") : Color(hex: "F0F0F0")
    }

    var gridLine: Color {
        isDark ? Color(hex: "1F1F1F") : Color(hex: "E5E5E5")
    }

    // MARK: Text (Grayscale only)

    var textPrimary: Color {
        isDark ? Color(hex: "F5F5F5") : Color(hex: "111111")
    }

    var textDim: Color {
        isDark ? Color(hex: "888888") : Color(hex: "666666")
    }

    var textFaint: Color {
        isDark ? Color(hex: "444444") : Color(hex: "AAAAAA")
    }

    // MARK: Accent (White in dark, Black in light)

    var accent: Color {
        isDark ? Color(hex: "FFFFFF") : Color(hex: "000000")
    }

    var accentInverse: Color {
        isDark ? Color(hex: "000000") : Color(hex: "FFFFFF")
    }

    // MARK: Borders & Dividers

    var border: Color {
        isDark ? Color(hex: "2A2A2A") : Color(hex: "DDDDDD")
    }

    var divider: Color {
        isDark ? Color(hex: "333333") : Color(hex: "CCCCCC")
    }

    // MARK: CRT Overlays

    var scanlineColor: Color {
        isDark ? Color(hex: "000000").opacity(0.4) : Color(hex: "000000").opacity(0.06)
    }

    var vignetteColor: Color {
        isDark ? Color(hex: "000000").opacity(0.5) : Color(hex: "000000").opacity(0.1)
    }
}

// MARK: - Environment Key

private struct TerminalColorSchemeKey: EnvironmentKey {
    static let defaultValue = TerminalColorScheme(colorScheme: .dark)
}

extension EnvironmentValues {
    var terminalColors: TerminalColorScheme {
        get { self[TerminalColorSchemeKey.self] }
        set { self[TerminalColorSchemeKey.self] = newValue }
    }
}
