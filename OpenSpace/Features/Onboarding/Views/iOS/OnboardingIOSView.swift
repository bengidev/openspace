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

          Spacer(minLength: context.topSectionSpacing)

          OnboardingHorizontalCapabilityStrip(
            chips: context.capabilityChips,
            hasAppeared: context.hasAppeared,
            reduceMotion: context.reduceMotion,
            spacing: 8,
            chipPadding: 12
          )
          .padding(.horizontal, 22)

          Spacer(minLength: context.heroSectionSpacing)

          OnboardingIOSHeroView(
            context: context,
            onContinue: onContinue
          )
          .padding(.horizontal, 28)

          Spacer(minLength: context.footerSectionSpacing)

          OnboardingIOSFooterView(context: context)
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
      }

      OnboardingSupportingNote(
        text: "OpenSpace is designed for developers who move between coding, visual ideation, and model orchestration.",
        hasAppeared: context.hasAppeared,
        alignment: .center,
        maxWidth: context.supportingNoteMaxWidth
      )
      .padding(.horizontal, 28)
      .padding(.bottom, 20)
    }
  }
}
