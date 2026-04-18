//
//  OnboardingIOSHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSHeroView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 18) {
      OnboardingSignalPill(isAnimated: context.isAnimated)

      VStack(spacing: 10) {
        Text("Calm Systems for Fast Builders")
          .font(.system(size: 38, weight: .medium, design: .default))
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 18)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
            value: context.hasAppeared
          )

        Text("Bring code, prompts, and image generation into one local-first workspace that feels composed even when the work is not.")
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white.opacity(0.72))
          .frame(maxWidth: 520)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 14)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
            value: context.hasAppeared
          )
      }

      OnboardingPrimaryButton(
        title: "Enter OpenSpace",
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        action: onContinue
      )
    }
  }
}
