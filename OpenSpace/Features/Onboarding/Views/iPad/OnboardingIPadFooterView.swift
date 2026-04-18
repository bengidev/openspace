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
      alignment: .center
    )
  }
}
