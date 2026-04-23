//
//  OnboardingMacView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacView: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  private var layout: OnboardingMacLayout {
    OnboardingMacLayout(context: context)
  }

  var body: some View {
    VStack(spacing: 0) {
      OnboardingMacPanel(
        cornerRadius: layout.panelCornerRadius,
        maxWidth: layout.panelMaxWidth,
        minHeight: layout.panelMinHeight,
        horizontalPadding: layout.panelHorizontalPadding,
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        contentAlignment: .topLeading
      ) {
        VStack(alignment: .leading, spacing: layout.sectionSpacing) {
          OnboardingMacHeaderView()
            .accessibilityIdentifier("onboarding.mac.header-container")

          OnboardingMacHeroView(
            context: context,
            layout: layout,
            onContinue: onContinue
          )
          .accessibilityIdentifier("onboarding.mac.hero-container")

          VStack(alignment: .leading, spacing: 10) {
            OnboardingMacFooterView(context: context)
              .accessibilityIdentifier("onboarding.mac.footer-container")

            OnboardingMacSupportingNote(
              text: "macOS onboarding leans into a desktop workbench posture, with enough structure to orient you before the main workspace opens.",
              hasAppeared: context.hasAppeared,
              alignment: .leading,
              maxWidth: layout.supportingNoteMaxWidth
            )
            .accessibilityIdentifier("onboarding.mac.supporting-note")
          }
          .padding(.top, layout.footerTopPadding)
          .overlay(alignment: .top) {
            Rectangle()
              .fill(ThemeColor.chromeStroke(for: colorScheme))
              .frame(height: 1)
          }
        }
        .padding(.horizontal, layout.panelHorizontalInset)
        .padding(.top, layout.panelTopPadding)
        .padding(.bottom, layout.panelBottomPadding)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .accessibilityIdentifier("onboarding.mac.content")
  }
}

#Preview("Desktop Onboarding Content") {
  OnboardingMacView(
    context: OnboardingPreviewSupport.context(
      variant: .mac,
      size: CGSize(width: 1120, height: 620)
    ),
    onContinue: {}
  )
  .padding(24)
  .onboardingPreviewSurface(size: CGSize(width: 1120, height: 620))
}

private struct OnboardingMacPanel<Content: View>: View {
  let cornerRadius: CGFloat
  let maxWidth: CGFloat?
  let minHeight: CGFloat
  let horizontalPadding: CGFloat
  let hasAppeared: Bool
  let reduceMotion: Bool
  let contentAlignment: Alignment
  @ViewBuilder let content: Content

  var body: some View {
    OnboardingHeroPanel(
      style: .desktopCanvas,
      cornerRadius: cornerRadius
    ) {
      content
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: contentAlignment)
    }
    .frame(maxWidth: maxWidth)
    .padding(.horizontal, horizontalPadding)
    .opacity(hasAppeared ? 1 : 0)
    .offset(y: hasAppeared ? 0 : 26)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.9), value: hasAppeared)
    .accessibilityIdentifier("onboarding.mac.panel")
  }
}

private struct OnboardingMacSupportingNote: View {
  @Environment(\.colorScheme) private var colorScheme
  let text: String
  let hasAppeared: Bool
  let alignment: TextAlignment
  let maxWidth: CGFloat?

  var body: some View {
    Text(text)
      .font(.footnote)
      .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
      .multilineTextAlignment(alignment)
      .frame(maxWidth: maxWidth)
      .frame(maxWidth: .infinity, alignment: .leading)
      .opacity(hasAppeared ? 1 : 0)
      .offset(y: hasAppeared ? 0 : 10)
      .animation(.easeOut(duration: 0.8).delay(0.55), value: hasAppeared)
  }
}
