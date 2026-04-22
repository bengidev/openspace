//
//  ThemeColors.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 17/04/26.
//

import SwiftUI

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
  static let glassTint = accent300.opacity(0.18)
  static let glassHighlight = accent100.opacity(0.24)
  static let glassShadow = Color.black.opacity(0.32)
  static let glow = accent.opacity(0.18)

  static func panelFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? neutral700.opacity(0.92) : Color.white.opacity(0.96)
  }

  static func panelSecondaryFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? neutral700.opacity(0.72) : neutral300.opacity(0.72)
  }

  static func subtlePanelFill(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white.opacity(0.08) : accent100.opacity(0.62)
  }

  static func elevatedStroke(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white.opacity(0.10) : accent100.opacity(0.85)
  }

  static func elevatedShadow(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.black.opacity(0.26) : accent300.opacity(0.12)
  }

  static func overlayTextPrimary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white : neutral1000
  }

  static func overlayTextSecondary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white.opacity(0.82) : neutral700.opacity(0.90)
  }

  static func overlayTextTertiary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white.opacity(0.62) : neutral500.opacity(0.92)
  }

  static func chromeFill(for colorScheme: ColorScheme, emphasis: Double = 1) -> Color {
    if colorScheme == .dark {
      return Color.white.opacity(0.10 * emphasis)
    } else {
      return Color.white.opacity(0.96)
    }
  }

  static func chromeStroke(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color.white.opacity(0.08) : accent100.opacity(0.92)
  }
}

// MARK: - View Extensions

extension View {
  /// Applies the OpenSpace shared theme tokens without forcing a color scheme.
  func openSpaceTheme() -> some View {
    self
      .background(ThemeColor.backgroundPrimary)
      .tint(ThemeColor.accent)
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
