//
//  ThemeColors.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 17/04/26.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

// MARK: - Theme Definition

struct AppTheme {
  static let colorHuntCream = Color(hex: "E9E3DF")
  static let colorHuntOrange = Color(hex: "FF7A30")
  static let colorHuntInk = Color(hex: "0B0B0B")
  static let colorHuntInkRaised = Color(hex: "171717")

  static let vanillaCream = colorHuntCream
  static let vanillaCreamMuted = Color(hex: "D8D2CF")

  static let background = Color("BackgroundPrimary")
  static let primaryText = Color("TextPrimary")
  static let secondaryText = Color("TextSecondary")

  static let primaryGradient = LinearGradient(
    colors: [colorHuntInkRaised, colorHuntOrange],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )

  static let softBlend = LinearGradient(
    stops: [
      .init(color: colorHuntInk, location: 0),
      .init(color: colorHuntInkRaised, location: 0.68),
      .init(color: colorHuntCream, location: 1),
    ],
    startPoint: .top,
    endPoint: .bottom
  )
}

// MARK: - Hex Helpers

extension Color {
  init(hex: String) {
    let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    Scanner(string: sanitized).scanHexInt64(&value)

    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64

    switch sanitized.count {
    case 3:
      (a, r, g, b) = (
        255,
        (value >> 8) * 17,
        (value >> 4 & 0xF) * 17,
        (value & 0xF) * 17
      )
    case 6:
      (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
    case 8:
      (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

#if canImport(UIKit)
  extension UIColor {
    convenience init?(hex: String) {
      let sanitized = hex
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "#", with: "")
      var rgb: UInt64 = 0
      Scanner(string: sanitized).scanHexInt64(&rgb)

      let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
      let green = CGFloat((rgb & 0x00FF00) >> 8) / 255
      let blue = CGFloat(rgb & 0x0000FF) / 255

      self.init(red: red, green: green, blue: blue, alpha: 1)
    }
  }
#endif

// MARK: - Color Theme

/// Centralized color tokens for the OpenSpace design system.
/// All colors reference the Asset Catalog which supports light/dark mode.
enum ThemeColor {
  // MARK: - Accent
  static let accent = Color("AccentColor")
  static let accent100 = Color("Accent100")
  static let accent200 = Color("Accent200")
  static let accent300 = Color("Accent300")

  // MARK: - Backgrounds
  static let backgroundPrimary = Color("BackgroundPrimary")
  static let backgroundSecondary = Color("BackgroundSecondary")

  // MARK: - Surface & Borders
  static let surface = Color("SurfaceColor")
  static let border = Color("BorderColor")

  // MARK: - Text
  static let textPrimary = Color("TextPrimary")
  static let textSecondary = Color("TextSecondary")

  // MARK: - Neutrals
  static let neutral300 = Color("Neutral300")
  static let neutral500 = Color("Neutral500")
  static let neutral700 = Color("Neutral700")
  static let neutral1000 = Color("Neutral1000")

  // MARK: - Bubbles
  static let assistantBubble = Color("AssistantBubble")
  static let userBubble = Color("UserBubble")

  // MARK: - Semantic
  static let destructive = Color("DestructiveColor")

  // MARK: - Frosted Surfaces
  static let glassTint = accent100.opacity(0.14)
  static let glassHighlight = accent100.opacity(0.24)
  static let glassShadow = AppTheme.colorHuntInk.opacity(0.24)
  static let glow = accent.opacity(0.18)

  static func panelFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInkRaised.opacity(0.38) : AppTheme.colorHuntCream.opacity(0.96)
  }

  static func panelSecondaryFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInkRaised.opacity(0.28) : AppTheme.vanillaCreamMuted.opacity(0.84)
  }

  static func subtlePanelFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.18) : accent100.opacity(0.74)
  }

  static func elevatedStroke(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.18) : accent300.opacity(0.14)
  }

  static func elevatedShadow(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInk.opacity(0.40) : accent300.opacity(0.12)
  }

  static func overlayTextPrimary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent100 : accent300
  }

  static func overlayTextSecondary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent100.opacity(0.84) : accent300.opacity(0.74)
  }

  static func overlayTextTertiary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent100.opacity(0.76) : accent300.opacity(0.56)
  }

  static func chromeFill(for colorScheme: ColorScheme, emphasis: Double = 1) -> Color {
    let normalizedEmphasis = min(max(emphasis, 0.4), 1.4)

    if colorScheme == .dark {
      return AppTheme.colorHuntInkRaised.opacity(0.20 * normalizedEmphasis)
    } else {
      return accent100.opacity(0.82)
    }
  }

  static func chromeStroke(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.18) : accent300.opacity(0.14)
  }

  static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200 : accent200
  }

  static func primaryButtonForeground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInk : AppTheme.colorHuntInk
  }

  static func accentHighlight(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200 : accent200
  }

  static func accentHighlightMuted(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.24) : accent200.opacity(0.16)
  }

  static func heroAccentGradient(for colorScheme: ColorScheme) -> LinearGradient {
    if colorScheme == .dark {
      return LinearGradient(
        colors: [accent200, accent100.opacity(0.78)],
        startPoint: .leading,
        endPoint: .trailing
      )
    } else {
      return AppTheme.primaryGradient
    }
  }

  static func orbHighlight(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.94) : accent200.opacity(0.70)
  }

  static func orbCore(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent200.opacity(0.82) : accent200
  }

  static func orbEdge(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? accent100.opacity(0.78) : accent300
  }
}

// MARK: - View Extensions

extension View {
  /// Applies the OpenSpace shared theme tokens.
  /// OpenSpace defaults to its Color Hunt dark appearance when no explicit app-level theme is chosen.
  func openSpaceTheme(preferredColorScheme: ColorScheme? = .dark) -> some View {
    modifier(OpenSpaceThemeModifier(preferredColorScheme: preferredColorScheme))
  }

  /// Applies a frosted glass treatment with subtle tint, stroke, and shadow.
  func openSpaceGlassPanel(
    cornerRadius: CGFloat = 28,
    tint: Color = ThemeColor.glassTint,
    stroke: Color = ThemeColor.glassHighlight
  ) -> some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    return self
      .background(.ultraThinMaterial, in: shape)
      .background(shape.fill(tint))
      .overlay(
        shape
          .strokeBorder(
            LinearGradient(
              colors: [stroke, ThemeColor.accent100.opacity(0.05)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
      )
      .shadow(color: ThemeColor.glassShadow, radius: 30, x: 0, y: 22)
  }
}

private struct OpenSpaceThemeModifier: ViewModifier {
  let preferredColorScheme: ColorScheme?

  @ViewBuilder
  func body(content: Content) -> some View {
    let themedContent = content
      .background(ThemeColor.backgroundPrimary)
      .tint(ThemeColor.accent)
      .preferredColorScheme(preferredColorScheme)

    if let preferredColorScheme {
      themedContent
        .environment(\.colorScheme, preferredColorScheme)
    } else {
      themedContent
    }
  }
}
