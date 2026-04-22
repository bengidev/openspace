//
//  OnboardingMacHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeaderView: View {
  var body: some View {
    ViewThatFits(in: .horizontal) {
      regularHeader
      compactHeader
    }
    .accessibilityIdentifier("onboarding.mac.header")
  }

  private var regularHeader: some View {
    HStack(alignment: .center, spacing: 16) {
      identityBlock

      Spacer(minLength: 16)

      HStack(spacing: 8) {
        headerBadge("DESKTOP SURFACE")
        headerBadge("SHARED STATE")
      }
    }
  }

  private var compactHeader: some View {
    VStack(alignment: .leading, spacing: 12) {
      identityBlock

      HStack(spacing: 8) {
        headerBadge("DESKTOP SURFACE")
        headerBadge("SHARED STATE")
      }
    }
  }

  private var identityBlock: some View {
    HStack(spacing: 12) {
      Image(systemName: "sparkles.rectangle.stack.fill")
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.15))
        .frame(width: 34, height: 34)
        .background(Circle().fill(Color.white.opacity(0.54)))

      VStack(alignment: .leading, spacing: 4) {
        Text("OpenSpace")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.15))

        Text("Compact macOS onboarding for local, multi-provider work")
          .font(.caption)
          .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19).opacity(0.72))
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
    }
    .accessibilityIdentifier("onboarding.mac.header.identity")
  }

  private func headerBadge(_ title: String) -> some View {
    Text(title)
      .font(.caption2.monospaced().weight(.medium))
      .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.15).opacity(0.92))
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Capsule().fill(Color.white.opacity(0.42)))
      .lineLimit(1)
      .minimumScaleFactor(0.85)
      .accessibilityIdentifier("onboarding.mac.header.badge.\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
  }
}

#Preview("Desktop Header") {
  OnboardingMacHeaderView()
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 1120, height: 120))
}
