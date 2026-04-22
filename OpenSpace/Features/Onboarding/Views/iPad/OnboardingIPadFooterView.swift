//
//  OnboardingIPadFooterView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadFooterView: View {
  let context: OnboardingRenderContext

  var body: some View {
    OnboardingMetadataBar(
      labels: [
        "IPAD WORKSPACE",
        "EXPANSIVE COMPOSITION",
        "FOCUS + BREADTH",
      ],
      hasAppeared: context.hasAppeared,
      alignment: .center,
      identifierPrefix: "onboarding.ipad.footer"
    )
  }
}

#Preview("iPad Footer") {
  OnboardingIPadFooterView(
    context: OnboardingPreviewSupport.context(
      variant: .ipad,
      size: CGSize(width: 834, height: 1194),
      capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
    )
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 834, height: 150))
}
