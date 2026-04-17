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
}

// MARK: - View Extensions

extension View {
  /// Applies the OpenSpace dark-first theme to the view.
  /// Sets background, tint, and preferred color scheme.
  func openSpaceTheme() -> some View {
    self
      .background(ThemeColor.backgroundPrimary)
      .tint(ThemeColor.accent)
      .preferredColorScheme(.dark)
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
