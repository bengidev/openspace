//
//  OnboardingVisuals.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI

enum OnboardingHeroPanelStyle {
  case floatingShowcase
  case desktopCanvas
}

struct OnboardingBackdrop: View {
  @Environment(\.colorScheme) private var colorScheme
  let isAnimated: Bool
  @State private var driftPhase = false

  var body: some View {
    ZStack {
      ThemeColor.backgroundPrimary
      LinearGradient(
        colors: backdropGradientColors,
        startPoint: .top,
        endPoint: .bottom
      )

      RadialGradient(
        colors: backdropHighlightColors,
        center: .top,
        startRadius: 32,
        endRadius: 420
      )
      .offset(x: driftPhase ? 18 : -14, y: driftPhase ? -134 : -112)
      .blur(radius: driftPhase ? 0 : 2)

      RadialGradient(
        colors: [
          ThemeColor.accent.opacity(colorScheme == .dark ? 0.16 : 0.12),
          .clear,
        ],
        center: .bottomLeading,
        startRadius: 20,
        endRadius: 320
      )
      .offset(x: driftPhase ? -72 : -102, y: driftPhase ? 138 : 114)
      .scaleEffect(driftPhase ? 1.08 : 0.96)

      PinstripeOverlay(
        stripeColor: colorScheme == .dark ? Color.white.opacity(0.03) : ThemeColor.accent100.opacity(0.26),
        stripeSpacing: 5,
        stripeWidth: 0.6
      )
      .blendMode(colorScheme == .dark ? .screen : .overlay)
      .opacity(driftPhase ? 0.24 : 0.34)
    }
    .ignoresSafeArea()
    .task(id: isAnimated) {
      guard isAnimated else {
        driftPhase = false
        return
      }

      withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
        driftPhase = true
      }
    }
  }

  private var backdropGradientColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.backgroundSecondary.opacity(0.92),
        ThemeColor.surface.opacity(0.96),
        ThemeColor.backgroundPrimary,
      ]
    } else {
      [
        ThemeColor.backgroundSecondary.opacity(0.96),
        ThemeColor.backgroundPrimary,
        ThemeColor.accent100.opacity(0.72),
      ]
    }
  }

  private var backdropHighlightColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.accent100.opacity(0.16),
        .clear,
      ]
    } else {
      [
        Color.white.opacity(0.62),
        .clear,
      ]
    }
  }
}

struct OnboardingHeroPanel<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  let style: OnboardingHeroPanelStyle
  let cornerRadius: CGFloat
  @ViewBuilder let content: Content

  init(
    style: OnboardingHeroPanelStyle = .floatingShowcase,
    cornerRadius: CGFloat = 32,
    @ViewBuilder content: () -> Content
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.content = content()
  }

  private var backgroundColors: [Color] {
    switch style {
    case .floatingShowcase:
      colorScheme == .dark
        ? [
          ThemeColor.accent100.opacity(0.22),
          ThemeColor.backgroundSecondary.opacity(0.86),
          ThemeColor.backgroundPrimary.opacity(0.98),
        ]
        : [
          Color.white.opacity(0.98),
          ThemeColor.backgroundSecondary.opacity(0.95),
          ThemeColor.accent100.opacity(0.82),
        ]
    case .desktopCanvas:
      colorScheme == .dark
        ? [
          ThemeColor.accent100.opacity(0.16),
          ThemeColor.backgroundSecondary.opacity(0.82),
          ThemeColor.backgroundPrimary.opacity(0.98),
        ]
        : [
          Color.white.opacity(0.98),
          ThemeColor.backgroundSecondary.opacity(0.92),
          ThemeColor.backgroundPrimary.opacity(0.96),
        ]
    }
  }

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    content
      .background(
        ZStack {
          LinearGradient(
            colors: backgroundColors,
            startPoint: .top,
            endPoint: .bottom
          )

          PinstripeOverlay(stripeColor: Color.white.opacity(0.18), stripeSpacing: 3.4, stripeWidth: 0.55)
            .mask(shape.fill(.white))
            .opacity(colorScheme == .dark ? (style == .desktopCanvas ? 0.18 : 0.32) : 0.12)

          LinearGradient(
            colors: overlayGradientColors,
            startPoint: .top,
            endPoint: .bottom
          )

          if style == .desktopCanvas {
            LinearGradient(
              colors: desktopShadeColors,
              startPoint: .top,
              endPoint: .bottom
            )

            RadialGradient(
              colors: desktopGlowColors,
              center: .leading,
              startRadius: 48,
              endRadius: 420
            )
            .offset(x: -72, y: 22)

            LinearGradient(
              colors: desktopBottomFadeColors,
              startPoint: .top,
              endPoint: .bottom
            )
          }
        }
        .clipShape(shape)
      )
      .overlay(
        shape
          .strokeBorder(
            LinearGradient(
              colors: [
                panelStrokeStart,
                panelStrokeEnd,
              ],
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: style == .desktopCanvas ? 0 : 1
          )
      )
      .shadow(
        color: colorScheme == .dark ? Color.black.opacity(style == .desktopCanvas ? 0.0 : 0.25) : ThemeColor.elevatedShadow(for: colorScheme),
        radius: style == .desktopCanvas ? 0 : 36,
        x: 0,
        y: style == .desktopCanvas ? 0 : 24
      )
  }

  private var overlayGradientColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.accent100.opacity(0.18),
        .clear,
        ThemeColor.backgroundPrimary.opacity(0.58),
      ]
    } else {
      [
        Color.white.opacity(0.46),
        .clear,
        ThemeColor.accent100.opacity(0.26),
      ]
    }
  }

  private var desktopShadeColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.backgroundPrimary.opacity(0.72),
        ThemeColor.backgroundPrimary.opacity(0.28),
        .clear,
      ]
    } else {
      [
        ThemeColor.accent100.opacity(0.20),
        ThemeColor.backgroundSecondary.opacity(0.14),
        .clear,
      ]
    }
  }

  private var desktopGlowColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.accent200.opacity(0.30),
        .clear,
      ]
    } else {
      [
        ThemeColor.accent.opacity(0.10),
        .clear,
      ]
    }
  }

  private var desktopBottomFadeColors: [Color] {
    if colorScheme == .dark {
      [
        Color.clear,
        ThemeColor.backgroundPrimary.opacity(0.12),
        ThemeColor.backgroundPrimary.opacity(0.24),
      ]
    } else {
      [
        Color.clear,
        ThemeColor.accent100.opacity(0.10),
        ThemeColor.accent100.opacity(0.18),
      ]
    }
  }

  private var panelStrokeStart: Color {
    colorScheme == .dark
      ? ThemeColor.accent100.opacity(style == .desktopCanvas ? 0.22 : 0.36)
      : ThemeColor.accent100.opacity(style == .desktopCanvas ? 0.62 : 0.92)
  }

  private var panelStrokeEnd: Color {
    colorScheme == .dark
      ? ThemeColor.accent100.opacity(style == .desktopCanvas ? 0.06 : 0.10)
      : ThemeColor.accent100.opacity(style == .desktopCanvas ? 0.12 : 0.28)
  }
}

struct PinstripeOverlay: View {
  let stripeColor: Color
  let stripeSpacing: CGFloat
  let stripeWidth: CGFloat

  init(
    stripeColor: Color = Color.white.opacity(0.15),
    stripeSpacing: CGFloat = 2,
    stripeWidth: CGFloat = 0.5
  ) {
    self.stripeColor = stripeColor
    self.stripeSpacing = stripeSpacing
    self.stripeWidth = stripeWidth
  }

  var body: some View {
    Canvas { context, size in
      var x: CGFloat = 0

      while x < size.width {
        let lineRect = CGRect(x: x, y: 0, width: stripeWidth, height: size.height)
        context.fill(Path(lineRect), with: .color(stripeColor))
        x += stripeSpacing
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
