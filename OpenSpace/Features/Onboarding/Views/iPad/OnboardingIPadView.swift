//
//  OnboardingIPadView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingIPadView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  private var layout: OnboardingIPadLayout {
    OnboardingIPadLayout(context: context)
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: layout.screenStackSpacing) {
        Spacer(minLength: layout.screenTopSpacing)

        OnboardingIPadPanel(
          cornerRadius: layout.panelCornerRadius,
          maxWidth: layout.panelMaxWidth,
          minHeight: layout.panelMinHeight,
          horizontalPadding: layout.panelHorizontalPadding,
          hasAppeared: context.hasAppeared,
          reduceMotion: context.reduceMotion,
          isAnimated: context.isAnimated
        ) {
          VStack(spacing: 0) {
            OnboardingIPadHeaderView()
              .accessibilityIdentifier("onboarding.ipad.header-container")
              .padding(.horizontal, layout.headerHorizontalPadding)
              .padding(.top, layout.headerTopPadding)

            Spacer(minLength: layout.capabilityTopSpacing)

            OnboardingIPadCapabilityStrip(
              chips: context.capabilityChips + ["Multiplatform", "Local-First"],
              hasAppeared: context.hasAppeared,
              reduceMotion: context.reduceMotion,
              spacing: layout.capabilitySpacing,
              chipPadding: layout.capabilityChipPadding,
              identifierPrefix: "onboarding.ipad.capabilities"
            )
            .padding(.horizontal, layout.capabilityHorizontalPadding)

            Spacer(minLength: layout.heroTopSpacing)

            OnboardingIPadHeroView(
              context: context,
              layout: layout,
              onContinue: onContinue
            )
            .accessibilityIdentifier("onboarding.ipad.hero-container")
            .padding(.horizontal, layout.heroHorizontalPadding)
            .padding(.bottom, layout.heroBottomPadding)

            Spacer(minLength: layout.footerTopSpacing)

            OnboardingIPadFooterView(context: context)
              .accessibilityIdentifier("onboarding.ipad.footer-container")
              .padding(.horizontal, layout.footerHorizontalPadding)
              .padding(.bottom, layout.footerBottomPadding)
          }
        }

        OnboardingIPadSupportingNote(
          text: "On iPad, onboarding uses the extra canvas for hierarchy and glanceable setup context, so the first screen already feels like a workspace instead of a blown-up phone sheet.",
          hasAppeared: context.hasAppeared,
          alignment: .center,
          maxWidth: layout.supportingNoteMaxWidth
        )
        .accessibilityIdentifier("onboarding.ipad.supporting-note")
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
    .accessibilityIdentifier("onboarding.ipad.scroll")
    .accessibilityIdentifier("onboarding.ipad.content")
  }
}

#Preview("iPad Onboarding Content") {
  OnboardingIPadView(
    context: OnboardingPreviewSupport.context(
      variant: .ipad,
      size: CGSize(width: 834, height: 1194),
      capabilityChips: OnboardingPreviewSupport.defaultCapabilityChips + ["Multiplatform", "Local-First"]
    ),
    onContinue: {}
  )
  .padding(.vertical, 24)
  .onboardingPreviewSurface(size: CGSize(width: 834, height: 1194))
}

private struct OnboardingIPadPanel<Content: View>: View {
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
    .accessibilityIdentifier("onboarding.ipad.panel")
  }
}

private struct OnboardingIPadCapabilityStrip: View {
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

private struct OnboardingIPadSupportingNote: View {
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
