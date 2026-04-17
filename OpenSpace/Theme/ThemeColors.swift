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
}
