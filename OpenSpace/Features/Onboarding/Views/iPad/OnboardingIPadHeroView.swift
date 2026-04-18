//
//  OnboardingIPadHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeroView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 22) {
      OnboardingSignalPill(
        isAnimated: context.isAnimated,
        label: "A larger canvas for coding, image generation, and local AI setup"
      )

      VStack(spacing: 12) {
        Text("OpenSpace Expands Without Splitting the Feature")
          .font(.system(size: 46, weight: .medium, design: .default))
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white)
          .frame(maxWidth: 760)
          .opacity(context.hasAppeared ? 1 : 0)
          .offset(y: context.hasAppeared ? 0 : 18)
          .animation(
            .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
            value: context.hasAppeared
          )

        Text("The iPad variant keeps the same onboarding state and intent, but produces a broader family of components with more room for hierarchy and capability context.")
          .font(.title3)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white.opacity(0.72))
          .frame(maxWidth: 700)
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
