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
        WorkspaceView {
          withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = false
          }
        }
        #if os(macOS)
          .frame(minWidth: 1180, idealWidth: 1280, minHeight: 740, idealHeight: 820)
        #endif
      } else {
        OnboardingView {
          withAnimation(.easeInOut(duration: 0.35)) {
            hasCompletedOnboarding = true
          }
        }
        #if os(macOS)
          .frame(minWidth: 980, idealWidth: 1120, minHeight: 620, idealHeight: 620)
        #endif
      }
    }
  }
}

#Preview("Onboarding") {
  AppRootView()
    .openSpaceTheme()
}
