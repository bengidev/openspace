//
//  AppRootView.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI

struct AppRootView: View {
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

  var body: some View {
    Group {
      if hasCompletedOnboarding {
        WorkspacePlaceholderView {
          withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = false
          }
        }
      } else {
        OnboardingView {
          withAnimation(.easeInOut(duration: 0.35)) {
            hasCompletedOnboarding = true
          }
        }
      }
    }
  }
}

#Preview("Onboarding") {
  AppRootView()
    .openSpaceTheme()
}
