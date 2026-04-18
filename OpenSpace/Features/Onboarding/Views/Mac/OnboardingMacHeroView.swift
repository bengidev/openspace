//
//  OnboardingMacHeroView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeroView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    HStack(alignment: .bottom, spacing: 28) {
      VStack(alignment: .leading, spacing: 18) {
        OnboardingSignalPill(
          isAnimated: context.isAnimated,
          label: "A desktop workbench for coding, image generation, and local AI setup"
        )

        VStack(alignment: .leading, spacing: 12) {
          Text("A Native Desktop Surface for Multi-Provider Work")
            .font(.system(size: 48, weight: .medium, design: .default))
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.white)
            .frame(maxWidth: 560, alignment: .leading)
            .opacity(context.hasAppeared ? 1 : 0)
            .offset(y: context.hasAppeared ? 0 : 18)
            .animation(
              .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.18),
              value: context.hasAppeared
            )

          Text("The macOS family keeps onboarding logic shared while producing a different render family: denser chrome, stronger information scent, and room for a real desktop posture.")
            .font(.title3)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.white.opacity(0.72))
            .frame(maxWidth: 560, alignment: .leading)
            .opacity(context.hasAppeared ? 1 : 0)
            .offset(y: context.hasAppeared ? 0 : 14)
            .animation(
              .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.28),
              value: context.hasAppeared
            )
        }

        OnboardingPrimaryButton(
          title: "Enter OpenSpace",
          hasAppeared: context.hasAppeared,
          reduceMotion: context.reduceMotion,
          action: onContinue
        )
      }

      VStack(alignment: .leading, spacing: 12) {
        Text("Desktop Notes")
          .font(.caption.weight(.semibold))
          .foregroundStyle(Color.white.opacity(0.68))

        VStack(alignment: .leading, spacing: 10) {
          OnboardingMacDetailRow(title: "Chrome", value: "Persistent workspace framing")
          OnboardingMacDetailRow(title: "Density", value: "More information per surface")
          OnboardingMacDetailRow(title: "Flow", value: "Shared state, variant-specific render")
        }
      }
      .padding(18)
      .frame(maxWidth: 280, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(Color.white.opacity(0.08))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
      )
      .opacity(context.hasAppeared ? 1 : 0)
      .offset(x: context.hasAppeared ? 0 : 18)
      .animation(
        .easeOut(duration: 0.75).delay(context.reduceMotion ? 0 : 0.36),
        value: context.hasAppeared
      )
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct OnboardingMacDetailRow: View {
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title.uppercased())
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(Color.white.opacity(0.42))

      Text(value)
        .font(.subheadline)
        .foregroundStyle(Color.white.opacity(0.78))
    }
  }
}
