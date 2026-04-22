//
//  OnboardingIOSFooterView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSFooterView: View {
  let context: OnboardingRenderContext

  var body: some View {
    OnboardingMetadataBar(
      labels: [
        "FIRST-RUN ONBOARDING",
        "FUTURISTIC CALM",
        "LOCAL-FIRST",
      ],
      hasAppeared: context.hasAppeared,
      alignment: .center,
      identifierPrefix: "onboarding.ios.footer"
    )
  }
}

#Preview("iPhone Footer") {
  OnboardingIOSFooterView(
    context: OnboardingPreviewSupport.context(
      variant: .ios,
      size: CGSize(width: 390, height: 844)
    )
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 390, height: 150))
}
