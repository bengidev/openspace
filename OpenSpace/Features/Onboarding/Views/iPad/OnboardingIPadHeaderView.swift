//
//  OnboardingIPadHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadHeaderView: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    ViewThatFits(in: .horizontal) {
      regularHeader
      compactHeader
    }
    .accessibilityIdentifier("onboarding.ipad.header")
  }

  private var regularHeader: some View {
    HStack {
      leadingButton
      Spacer(minLength: 12)
      centerBadge
      Spacer(minLength: 12)
      trailingButton
    }
  }

  private var compactHeader: some View {
    VStack(spacing: 12) {
      HStack {
        leadingButton
        Spacer(minLength: 12)
        trailingButton
      }

      centerBadge
        .frame(maxWidth: .infinity)
    }
  }

  private var leadingButton: some View {
    Button {} label: {
      Image(systemName: "plus")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: 40, height: 40)
        .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("OpenSpace mark")
    .accessibilityIdentifier("onboarding.ipad.header.leading-button")
  }

  private var centerBadge: some View {
    Text("OpenSpace for iPad")
      .font(.caption.weight(.semibold))
      .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Capsule().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 0.6)))
      .accessibilityIdentifier("onboarding.ipad.header.center-badge")
  }

  private var trailingButton: some View {
    Button {} label: {
      Image(systemName: "waveform.path.ecg")
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(ThemeColor.overlayTextTertiary(for: colorScheme))
        .frame(width: 40, height: 40)
        .background(Circle().fill(ThemeColor.chromeFill(for: colorScheme, emphasis: 1.2)))
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Ambient activity indicator")
    .accessibilityIdentifier("onboarding.ipad.header.trailing-button")
  }
}

#Preview("iPad Header") {
  OnboardingIPadHeaderView()
    .padding(24)
    .onboardingPreviewSurface(size: CGSize(width: 834, height: 130))
}
