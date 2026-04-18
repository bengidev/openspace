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
      alignment: .center
    )
  }
}
