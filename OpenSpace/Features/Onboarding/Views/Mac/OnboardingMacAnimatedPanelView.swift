//
//  OnboardingMacAnimatedPanelView.swift
//  OpenSpace
//
//  macOS-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingMacAnimatedPanel

struct OnboardingMacAnimatedPanel<Content: View>: View {
    // MARK: Lifecycle

    init(
        style: OnboardingHeroPanelStyle = .floatingShowcase,
        cornerRadius: CGFloat,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat,
        horizontalPadding: CGFloat,
        hasAppeared: Bool,
        reduceMotion: Bool,
        isAnimated: Bool = false,
        contentAlignment: Alignment = .center,
        identifierPrefix: String,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.horizontalPadding = horizontalPadding
        self.hasAppeared = hasAppeared
        self.reduceMotion = reduceMotion
        self.isAnimated = isAnimated
        self.contentAlignment = contentAlignment
        self.identifierPrefix = identifierPrefix
        self.content = content()
    }

    // MARK: Internal

    let style: OnboardingHeroPanelStyle
    let cornerRadius: CGFloat
    let maxWidth: CGFloat?
    let minHeight: CGFloat
    let horizontalPadding: CGFloat
    let hasAppeared: Bool
    let reduceMotion: Bool
    let isAnimated: Bool
    let contentAlignment: Alignment
    let identifierPrefix: String
    @ViewBuilder let content: Content

    var body: some View {
        OnboardingHeroPanel(
            style: style,
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
        .modifier(
            FloatingPanelEffect(isActive: style == .floatingShowcase && isAnimated)
        )
        .accessibilityIdentifier("\(identifierPrefix).panel")
    }
}

#Preview("Onboarding Animated Panel Component") {
    let context = OnboardingPreviewSupport.context(
        variant: .mac,
        size: CGSize(width: 1280, height: 820)
    )
    let layout = OnboardingMacLayout(context: context)

    OnboardingMacAnimatedPanel(
        style: .desktopCanvas,
        cornerRadius: layout.panelCornerRadius,
        maxWidth: layout.panelMaxWidth,
        minHeight: max(220, layout.panelMinHeight),
        horizontalPadding: layout.panelHorizontalPadding,
        hasAppeared: context.hasAppeared,
        reduceMotion: context.reduceMotion,
        isAnimated: context.isAnimated,
        identifierPrefix: "preview.onboarding.mac"
    ) {
        VStack(spacing: 16) {
            Text("Mac platform panel")
                .font(.headline.weight(.semibold))
            Text("Preview isolates the platform-owned animated panel component.")
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .padding(32)
    }
    .onboardingComponentPreviewSurface()
}
