import SwiftUI

enum WorkspacePalette {
  static func shellTop(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInkRaised.opacity(0.98) : ThemeColor.backgroundSecondary.opacity(0.94)
  }

  static func shellBottom(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.backgroundPrimary : ThemeColor.backgroundPrimary.opacity(0.94)
  }

  static func shellStroke(for colorScheme: ColorScheme) -> Color {
    ThemeColor.chromeStroke(for: colorScheme)
  }

  static func sidebarBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInk.opacity(0.92) : ThemeColor.backgroundSecondary.opacity(0.78)
  }

  static func sidebarSelection(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.accent200.opacity(0.18) : ThemeColor.subtlePanelFill(for: colorScheme)
  }

  static func panelBackground(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInkRaised.opacity(0.98) : ThemeColor.panelFill(for: colorScheme)
  }

  static func panelSecondary(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInkRaised.opacity(0.86) : ThemeColor.subtlePanelFill(for: colorScheme)
  }

  static func cardStroke(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.accent200.opacity(0.20) : ThemeColor.elevatedStroke(for: colorScheme)
  }

  static let primaryText = ThemeColor.textPrimary
  static let secondaryText = ThemeColor.textSecondary
  static func tertiaryText(for colorScheme: ColorScheme) -> Color {
    ThemeColor.overlayTextTertiary(for: colorScheme)
  }

  static let accent = ThemeColor.accent
  static func accentSoft(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? ThemeColor.accent200.opacity(0.16) : ThemeColor.accent200.opacity(0.14)
  }

  static func border(for colorScheme: ColorScheme) -> Color {
    ThemeColor.chromeStroke(for: colorScheme)
  }

  static func shadow(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? AppTheme.colorHuntInk.opacity(0.34) : ThemeColor.elevatedShadow(for: colorScheme)
  }

  static func orbCore(for colorScheme: ColorScheme) -> Color {
    ThemeColor.orbCore(for: colorScheme)
  }

  static func orbEdge(for colorScheme: ColorScheme) -> Color {
    ThemeColor.orbEdge(for: colorScheme)
  }

  static func accentHighlight(for colorScheme: ColorScheme) -> Color {
    ThemeColor.accentHighlight(for: colorScheme)
  }

  static func accentHighlightMuted(for colorScheme: ColorScheme) -> Color {
    ThemeColor.accentHighlightMuted(for: colorScheme)
  }

  static func heroAccentGradient(for colorScheme: ColorScheme) -> LinearGradient {
    ThemeColor.heroAccentGradient(for: colorScheme)
  }

  static func primaryButtonBackground(for colorScheme: ColorScheme) -> Color {
    ThemeColor.primaryButtonBackground(for: colorScheme)
  }

  static func primaryButtonForeground(for colorScheme: ColorScheme) -> Color {
    ThemeColor.primaryButtonForeground(for: colorScheme)
  }
}
