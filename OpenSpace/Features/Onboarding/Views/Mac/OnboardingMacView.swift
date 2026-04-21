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
    OnboardingPlatformPanel(variant: .mac, context: context) {
      VStack(alignment: .leading, spacing: context.desktopSectionSpacing) {
        OnboardingMacHeaderView()

        OnboardingMacHeroView(
          context: context,
          onContinue: onContinue
        )

        VStack(alignment: .leading, spacing: 10) {
          OnboardingMacFooterView(context: context)

          OnboardingSupportingNote(
            text: "The macOS surface leans into dense desktop posture: shared onboarding logic, stronger workspace framing, and room for durable chrome without feeling heavy.",
            hasAppeared: context.hasAppeared,
            alignment: .leading,
            maxWidth: context.supportingNoteMaxWidth
          )
        }
        .padding(.top, context.macSpacingBeforeFooter)
        .overlay(alignment: .top) {
          Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
        }
      }
      .padding(.horizontal, context.desktopPanelPadding)
      .padding(.top, max(context.desktopPanelPadding - 4, 12))
      .padding(.bottom, max(context.desktopPanelPadding - 20, 6))
    }
  }
}
