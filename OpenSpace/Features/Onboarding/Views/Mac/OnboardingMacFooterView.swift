//
//  OnboardingMacFooterView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacFooterView: View {
  let context: OnboardingRenderContext

  var body: some View {
    OnboardingMetadataBar(
      labels: [
        "LOCAL-FIRST WORKBENCH",
        "DESKTOP DENSITY",
        "MULTI-WINDOW READY",
      ],
      hasAppeared: context.hasAppeared,
      alignment: .leading
    )
  }
}
