//
//  OnboardingIPadHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeaderView: View {
  var body: some View {
    OnboardingHeaderChromeView(
      centerText: "OpenSpace for iPad",
      badgeOpacity: 0.6,
      buttonSize: 40,
      identifierPrefix: "onboarding.ipad.header"
    )
  }
}

#Preview("iPad Header") {
  OnboardingIPadHeaderView()
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 834, height: 130))
}
