//
//  OnboardingView.swift
//  OpenSpace
//
//  Created by Codex on 17/04/26.
//

import SwiftUI

struct OnboardingView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var hasAppeared = false

  let onContinue: () -> Void

  private let capabilityChips = [
    "Code",
    "Images",
    "Research",
    "Automation",
  ]

  var body: some View {
    ZStack {
      OnboardingBackdrop(isAnimated: !reduceMotion && hasAppeared)

      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 28) {
          Spacer(minLength: 18)

          OnboardingHeroPanel(cornerRadius: 34) {
            VStack(spacing: 0) {
              OnboardingTopBar()
                .padding(.horizontal, 22)
                .padding(.top, 22)

              Spacer(minLength: 44)

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(Array(capabilityChips.enumerated()), id: \.element) { index, chip in
                    OnboardingCapabilityChip(
                      title: chip,
                      isVisible: hasAppeared,
                      reduceMotion: reduceMotion,
                      delay: Double(index) * 0.08
                    )
                  }
                }
                .padding(.horizontal, 22)
              }
              .scrollClipDisabled()

              Spacer(minLength: 104)

              VStack(spacing: 18) {
                OnboardingSignalPill(
                  isAnimated: !reduceMotion && hasAppeared
                )

                VStack(spacing: 10) {
                  Text("Calm Systems for Fast Builders")
                    .font(.system(size: 38, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 18)
                    .animation(
                      .easeOut(duration: 0.75).delay(reduceMotion ? 0 : 0.18),
                      value: hasAppeared
                    )

                  Text("Bring code, prompts, and image generation into one local-first workspace that feels composed even when the work is not.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.72))
                    .frame(maxWidth: 520)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 14)
                    .animation(
                      .easeOut(duration: 0.75).delay(reduceMotion ? 0 : 0.28),
                      value: hasAppeared
                    )
                }

                Button(action: onContinue) {
                  Text("Enter OpenSpace")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.06, green: 0.12, blue: 0.14))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                      Capsule()
                        .fill(Color.white)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Finish onboarding and enter the current app shell")
                .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.94))
                .opacity(hasAppeared ? 1 : 0)
                .shadow(
                  color: Color.white.opacity(reduceMotion ? 0.08 : 0.16),
                  radius: hasAppeared ? 14 : 0,
                  x: 0,
                  y: 6
                )
                .animation(
                  .easeOut(duration: 0.75).delay(reduceMotion ? 0 : 0.38),
                  value: hasAppeared
                )
                .modifier(
                  AmbientBreathingEffect(
                    isActive: !reduceMotion && hasAppeared
                  )
                )
              }
              .padding(.horizontal, 28)

              Spacer(minLength: 52)

              HStack {
                Text("FIRST-RUN ONBOARDING")
                Spacer()
                Text("FUTURISTIC CALM")
                Spacer()
                Text("LOCAL-FIRST")
              }
              .font(.caption2.monospaced())
              .foregroundStyle(Color.white.opacity(0.32))
              .padding(.horizontal, 24)
              .padding(.bottom, 22)
              .opacity(hasAppeared ? 1 : 0)
              .animation(
                .easeOut(duration: 0.8).delay(reduceMotion ? 0 : 0.48),
                value: hasAppeared
              )
            }
            .frame(minHeight: 600)
          }
          .frame(maxWidth: 820)
          .padding(.horizontal, 18)
          .opacity(hasAppeared ? 1 : 0)
          .offset(y: hasAppeared ? 0 : 26)
          .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
          .animation(.easeOut(duration: 0.9), value: hasAppeared)
          .modifier(
            FloatingPanelEffect(
              isActive: !reduceMotion && hasAppeared
            )
          )

          Text("OpenSpace is designed for developers who move between coding, visual ideation, and model orchestration.")
            .font(.footnote)
            .foregroundStyle(Color.white.opacity(0.56))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .padding(.bottom, 20)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 10)
            .animation(
              .easeOut(duration: 0.8).delay(reduceMotion ? 0 : 0.55),
              value: hasAppeared
            )
        }
        .frame(maxWidth: .infinity)
      }
      .safeAreaPadding(.vertical, 10)
    }
    .task {
      guard !hasAppeared else { return }
      hasAppeared = true
    }
  }
}

private struct OnboardingTopBar: View {
  var body: some View {
    HStack {
      Button {} label: {
        Image(systemName: "plus")
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(Color(red: 0.05, green: 0.11, blue: 0.13))
          .frame(width: 36, height: 36)
          .background(Circle().fill(Color.white.opacity(0.62)))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("OpenSpace mark")

      Spacer()

      Text("OpenSpace")
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.56)))

      Spacer()

      Button {} label: {
        Image(systemName: "waveform.path.ecg")
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(Color(red: 0.05, green: 0.11, blue: 0.13))
          .frame(width: 36, height: 36)
          .background(Circle().fill(Color.white.opacity(0.62)))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Ambient activity indicator")
    }
  }
}

private struct OnboardingCapabilityChip: View {
  let title: String
  let isVisible: Bool
  let reduceMotion: Bool
  let delay: Double

  var body: some View {
    Text(title)
      .font(.caption)
      .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19))
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(Color.white.opacity(0.56))
      )
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 10)
      .scaleEffect(reduceMotion ? 1 : (isVisible ? 1 : 0.96))
      .animation(
        .easeOut(duration: 0.55).delay(reduceMotion ? 0 : delay),
        value: isVisible
      )
  }
}

private struct OnboardingSignalPill: View {
  let isAnimated: Bool

  var body: some View {
    HStack(spacing: 8) {
      AnimatedSignalDot(isAnimated: isAnimated)

      Text("One workspace for coding, image generation, and local AI setup")
        .font(.caption)
        .foregroundStyle(Color.white.opacity(0.75))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
      Capsule()
        .fill(Color.white.opacity(0.08))
    )
    .overlay(
      Capsule()
        .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.8)
    )
  }
}

private struct AnimatedSignalDot: View {
  let isAnimated: Bool
  @State private var isExpanded = false

  var body: some View {
    Circle()
      .fill(Color.white)
      .frame(width: 6, height: 6)
      .overlay(
        Circle()
          .stroke(Color.white.opacity(isAnimated ? 0.22 : 0.32), lineWidth: 5)
          .frame(width: isExpanded ? 20 : 16, height: isExpanded ? 20 : 16)
          .opacity(isExpanded ? 0.25 : 0.65)
      )
      .task(id: isAnimated) {
        guard isAnimated else {
          isExpanded = false
          return
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
          isExpanded = true
        }
      }
  }
}

private struct FloatingPanelEffect: ViewModifier {
  let isActive: Bool
  @State private var isFloating = false

  func body(content: Content) -> some View {
    content
      .offset(y: isFloating ? -4 : 4)
      .task(id: isActive) {
        guard isActive else {
          isFloating = false
          return
        }

        withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
          isFloating = true
        }
      }
  }
}

private struct AmbientBreathingEffect: ViewModifier {
  let isActive: Bool
  @State private var isExpanded = false

  func body(content: Content) -> some View {
    content
      .scaleEffect(isExpanded ? 1.015 : 1)
      .task(id: isActive) {
        guard isActive else {
          isExpanded = false
          return
        }

        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
          isExpanded = true
        }
      }
  }
}

#Preview {
  OnboardingView {}
    .openSpaceTheme()
}
