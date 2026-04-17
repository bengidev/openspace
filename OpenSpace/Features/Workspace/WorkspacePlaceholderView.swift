//
//  WorkspacePlaceholderView.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI

struct WorkspacePlaceholderView: View {
  let replayOnboarding: () -> Void

  var body: some View {
    ZStack {
      OnboardingBackdrop(isAnimated: false)

      VStack(spacing: 18) {
        Text("Onboarding complete")
          .font(.title2.weight(.semibold))
          .foregroundStyle(Color.white)

        Text("The workspace shell has been intentionally kept minimal while the onboarding direction is being refined.")
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.white.opacity(0.66))
          .frame(maxWidth: 320)

        Button("Replay Onboarding", action: replayOnboarding)
          .font(.subheadline.weight(.semibold))
          .buttonStyle(.plain)
          .foregroundStyle(Color(red: 0.05, green: 0.11, blue: 0.13))
          .padding(.horizontal, 20)
          .padding(.vertical, 13)
          .background(Capsule().fill(Color.white))
      }
      .padding(28)
    }
  }
}

#Preview {
  WorkspacePlaceholderView {}
    .openSpaceTheme()
}
