//
//  WorkspaceBackdropView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceBackdrop: View {
  @Environment(\.colorScheme) private var colorScheme
  let isAnimated: Bool
  @State private var driftPhase = false

  var body: some View {
    ZStack {
      ThemeColor.backgroundPrimary

      LinearGradient(
        colors: backgroundGradientColors,
        startPoint: .top,
        endPoint: .bottom
      )

      RadialGradient(
        colors: topGlowColors,
        center: .topLeading,
        startRadius: 28,
        endRadius: 420
      )
      .offset(x: driftPhase ? 26 : -18, y: driftPhase ? -72 : -46)

      RadialGradient(
        colors: accentGlowColors,
        center: .bottomLeading,
        startRadius: 18,
        endRadius: 360
      )
      .offset(x: driftPhase ? -48 : -88, y: driftPhase ? 104 : 136)
      .scaleEffect(driftPhase ? 1.05 : 0.95)

      LinearGradient(
        colors: chromeBandColors,
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(maxHeight: 220)
      .frame(maxHeight: .infinity, alignment: .top)
    }
    .ignoresSafeArea()
    .task(id: isAnimated) {
      guard isAnimated else {
        driftPhase = false
        return
      }

      withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
        driftPhase = true
      }
    }
  }

  private var backgroundGradientColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.surface.opacity(0.94),
        ThemeColor.backgroundSecondary.opacity(0.96),
        ThemeColor.backgroundPrimary,
      ]
    } else {
      [
        ThemeColor.backgroundSecondary.opacity(0.96),
        ThemeColor.backgroundPrimary,
        ThemeColor.accent100.opacity(0.56),
      ]
    }
  }

  private var topGlowColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.accent100.opacity(0.12),
        .clear,
      ]
    } else {
      [
        ThemeColor.accent100.opacity(0.72),
        .clear,
      ]
    }
  }

  private var accentGlowColors: [Color] {
    [
      ThemeColor.accent.opacity(colorScheme == .dark ? 0.14 : 0.10),
      .clear,
    ]
  }

  private var chromeBandColors: [Color] {
    if colorScheme == .dark {
      [
        ThemeColor.accent100.opacity(0.06),
        .clear,
      ]
    } else {
      [
        ThemeColor.accent100.opacity(0.34),
        .clear,
      ]
    }
  }
}
