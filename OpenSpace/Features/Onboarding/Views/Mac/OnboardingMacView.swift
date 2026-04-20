//
//  OnboardingMacView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      OnboardingPlatformPanel(variant: .mac, context: context) {
        VStack(spacing: 0) {
          OnboardingMacHeaderView()
            .padding(.horizontal, 28)
            .padding(.top, 28)

          Spacer(minLength: 44)

          OnboardingMacCapabilityStrip(
            chips: context.capabilityChips,
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion
          )
          .padding(.horizontal, 28)

          Spacer(minLength: 104)

          OnboardingMacHeroView(
            context: context,
            onContinue: onContinue
          )
          .padding(.horizontal, 32)

          Spacer(minLength: 52)

          OnboardingMacFooterView(context: context)
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
      }

      OnboardingSupportingNote(
        text: "The macOS family leans into desktop posture: wider hierarchy, stronger information scent, and room for durable workspace chrome without changing onboarding logic.",
        hasAppeared: context.hasAppeared,
        alignment: .leading,
        maxWidth: 840
      )
      .padding(.horizontal, 28)
      .padding(.bottom, 20)
    }
  }
}
