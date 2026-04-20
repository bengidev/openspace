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
  let isAnimated: Bool
  @State private var driftPhase = false

  var body: some View {
    ZStack {
      Color(red: 0.04, green: 0.11, blue: 0.14)
      LinearGradient(
        colors: [
          Color(red: 0.24, green: 0.34, blue: 0.39).opacity(0.82),
          Color(red: 0.07, green: 0.15, blue: 0.18).opacity(0.95),
          Color(red: 0.02, green: 0.08, blue: 0.10),
        ],
        startPoint: .top,
        endPoint: .bottom
      )

      RadialGradient(
        colors: [
          Color(red: 0.82, green: 0.88, blue: 0.90).opacity(0.16),
          .clear,
        ],
        center: .top,
        startRadius: 32,
        endRadius: 420
      )
      .offset(x: driftPhase ? 18 : -14, y: driftPhase ? -134 : -112)
      .blur(radius: driftPhase ? 0 : 2)

      RadialGradient(
        colors: [
          ThemeColor.accent100.opacity(0.14),
          .clear,
        ],
        center: .bottomLeading,
        startRadius: 20,
        endRadius: 320
      )
      .offset(x: driftPhase ? -72 : -102, y: driftPhase ? 138 : 114)
      .scaleEffect(driftPhase ? 1.08 : 0.96)

      PinstripeOverlay(stripeColor: Color.white.opacity(0.03), stripeSpacing: 5, stripeWidth: 0.6)
        .blendMode(.screen)
        .opacity(driftPhase ? 0.28 : 0.38)
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
}

struct OnboardingHeroPanel<Content: View>: View {
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
      [
        Color.white.opacity(0.94),
        Color(red: 0.88, green: 0.92, blue: 0.93).opacity(0.9),
        Color(red: 0.08, green: 0.17, blue: 0.21).opacity(0.92),
      ]
    case .desktopCanvas:
      [
        Color.white.opacity(0.9),
        Color(red: 0.82, green: 0.88, blue: 0.9).opacity(0.82),
        Color(red: 0.07, green: 0.15, blue: 0.18).opacity(0.94),
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
            .opacity(style == .desktopCanvas ? 0.18 : 0.32)

          LinearGradient(
            colors: [
              Color.white.opacity(0.28),
              .clear,
              Color(red: 0.01, green: 0.07, blue: 0.10).opacity(0.55),
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        }
        .clipShape(shape)
      )
      .overlay(
        shape
          .strokeBorder(
            LinearGradient(
              colors: [
                Color.white.opacity(style == .desktopCanvas ? 0.28 : 0.46),
                Color.white.opacity(style == .desktopCanvas ? 0.05 : 0.08),
              ],
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: 1
          )
      )
      .shadow(
        color: Color.black.opacity(style == .desktopCanvas ? 0.16 : 0.25),
        radius: style == .desktopCanvas ? 18 : 36,
        x: 0,
        y: style == .desktopCanvas ? 12 : 24
      )
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
