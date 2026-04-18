//
//  OnboardingIOSView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 28) {
      OnboardingPlatformPanel(variant: .ios, context: context) {
        VStack(spacing: 0) {
          OnboardingIOSHeaderView()
            .padding(.horizontal, 22)
            .padding(.top, 22)

          Spacer(minLength: 44)

          OnboardingHorizontalCapabilityStrip(
            chips: context.capabilityChips,
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion,
            spacing: 8,
            chipPadding: 12
          )
          .padding(.horizontal, 22)

          Spacer(minLength: 104)

          OnboardingIOSHeroView(
            context: context,
            onContinue: onContinue
          )
          .padding(.horizontal, 28)

          Spacer(minLength: 52)

          OnboardingIOSFooterView(context: context)
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
      }

      OnboardingSupportingNote(
        text: "OpenSpace is designed for developers who move between coding, visual ideation, and model orchestration.",
        hasAppeared: context.hasAppeared,
        alignment: .center,
        maxWidth: 620
      )
      .padding(.horizontal, 28)
      .padding(.bottom, 20)
    }
  }
}
