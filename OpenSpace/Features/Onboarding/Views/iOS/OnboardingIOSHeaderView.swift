//
//  OnboardingIOSHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSHeaderView: View {
  var body: some View {
    OnboardingHeaderChromeView(
      centerText: "OpenSpace",
      identifierPrefix: "onboarding.ios.header"
    )
  }
}

#Preview("iPhone Header") {
  OnboardingIOSHeaderView()
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 390, height: 120))
}
