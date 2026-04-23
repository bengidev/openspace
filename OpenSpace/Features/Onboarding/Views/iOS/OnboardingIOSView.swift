//
//  OnboardingIOSView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIOSView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  private var layout: OnboardingIOSLayout {
    OnboardingIOSLayout(context: context)
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: layout.screenStackSpacing) {
        Spacer(minLength: layout.screenTopSpacing)

        OnboardingIOSPanel(
          cornerRadius: layout.panelCornerRadius,
          maxWidth: layout.panelMaxWidth,
          minHeight: layout.panelMinHeight,
          horizontalPadding: layout.panelHorizontalPadding,
          hasAppeared: context.hasAppeared,
          reduceMotion: context.reduceMotion,
          isAnimated: context.isAnimated
        ) {
          VStack(spacing: 0) {
            OnboardingIOSHeaderView()
              .accessibilityIdentifier("onboarding.ios.header-container")
              .padding(.horizontal, layout.headerHorizontalPadding)
              .padding(.top, layout.headerTopPadding)

            OnboardingIOSCapabilityStrip(
              chips: context.capabilityChips,
              hasAppeared: context.hasAppeared,
              reduceMotion: context.reduceMotion,
              spacing: layout.capabilitySpacing,
              chipPadding: layout.capabilityChipPadding,
              identifierPrefix: "onboarding.ios.capabilities"
            )
            .padding(.top, layout.capabilityTopPadding)
            .padding(.horizontal, layout.capabilityHorizontalPadding)

            OnboardingIOSHeroView(
              context: context,
              layout: layout,
              onContinue: onContinue
            )
            .accessibilityIdentifier("onboarding.ios.hero-container")

            Spacer(minLength: layout.footerTopSpacing)

            OnboardingIOSFooterView(context: context)
              .accessibilityIdentifier("onboarding.ios.footer-container")
              .padding(.horizontal, layout.footerHorizontalPadding)
              .padding(.bottom, layout.footerBottomPadding)
          }
        }

        OnboardingIOSSupportingNote(
          text: "OpenSpace keeps first-run setup calm on iPhone, so you can understand the workspace quickly and keep momentum when you enter the app.",
          hasAppeared: context.hasAppeared,
          alignment: .center,
          maxWidth: layout.supportingNoteMaxWidth
        )
        .accessibilityIdentifier("onboarding.ios.supporting-note")
        .padding(.horizontal, layout.supportingNoteHorizontalPadding)
        .padding(.bottom, layout.supportingNoteBottomPadding)
      }
      .frame(
        maxWidth: .infinity,
        minHeight: layout.screenContentMinHeight,
        alignment: .top
      )
    }
    .safeAreaPadding(.vertical, layout.screenVerticalPadding)
    .accessibilityIdentifier("onboarding.ios.scroll")
    .accessibilityIdentifier("onboarding.ios.content")
  }
}

#Preview("iPhone Onboarding Content") {
  OnboardingIOSView(
    context: OnboardingPreviewSupport.context(
      variant: .ios,
      size: CGSize(width: 390, height: 844)
    ),
    onContinue: {}
  )
  .padding(.vertical, 18)
  .onboardingPreviewSurface(size: CGSize(width: 390, height: 844))
}

private struct OnboardingIOSPanel<Content: View>: View {
  let cornerRadius: CGFloat
  let maxWidth: CGFloat?
  let minHeight: CGFloat
  let horizontalPadding: CGFloat
  let hasAppeared: Bool
  let reduceMotion: Bool
  let isAnimated: Bool
  @ViewBuilder let content: Content

  var body: some View {
    OnboardingHeroPanel(
      style: .floatingShowcase,
      cornerRadius: cornerRadius
    ) {
      content
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .center)
    }
    .frame(maxWidth: maxWidth)
    .padding(.horizontal, horizontalPadding)
    .opacity(hasAppeared ? 1 : 0)
    .offset(y: hasAppeared ? 0 : 26)
    .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.985))
    .animation(.easeOut(duration: 0.9), value: hasAppeared)
    .modifier(FloatingPanelEffect(isActive: isAnimated))
    .accessibilityIdentifier("onboarding.ios.panel")
  }
}

private struct OnboardingIOSCapabilityStrip: View {
  let chips: [String]
  let hasAppeared: Bool
  let reduceMotion: Bool
  let spacing: CGFloat
  let chipPadding: CGFloat
  let identifierPrefix: String

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: spacing) {
        ForEach(Array(chips.enumerated()), id: \.element) { index, chip in
          OnboardingCapabilityChip(
            title: chip,
            isVisible: hasAppeared,
            reduceMotion: reduceMotion,
            delay: Double(index) * 0.08,
            horizontalPadding: chipPadding,
            identifier: "\(identifierPrefix).chip.\(chip.onboardingIdentifierSlug)"
          )
        }
      }
    }
    .scrollClipDisabled()
    .accessibilityIdentifier(identifierPrefix)
  }
}

private struct OnboardingIOSSupportingNote: View {
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
      .frame(maxWidth: .infinity, alignment: .center)
      .opacity(hasAppeared ? 1 : 0)
      .offset(y: hasAppeared ? 0 : 10)
      .animation(.easeOut(duration: 0.8).delay(0.55), value: hasAppeared)
  }
}
