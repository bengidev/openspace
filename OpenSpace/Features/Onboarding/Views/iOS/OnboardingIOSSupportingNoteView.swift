//
//  OnboardingIOSSupportingNoteView.swift
//  OpenSpace
//
//  iPhone-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingIOSSupportingNote

struct OnboardingIOSSupportingNote: View {
    // MARK: Lifecycle

    init(
        text: String,
        hasAppeared: Bool,
        alignment: TextAlignment,
        maxWidth: CGFloat? = nil,
        frameAlignment: Alignment = .center
    ) {
        self.text = text
        self.hasAppeared = hasAppeared
        self.alignment = alignment
        self.maxWidth = maxWidth
        self.frameAlignment = frameAlignment
    }

    // MARK: Internal

    let text: String
    let hasAppeared: Bool
    let alignment: TextAlignment
    let maxWidth: CGFloat?
    let frameAlignment: Alignment

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(ThemeColor.overlayTextSecondary(for: colorScheme))
            .multilineTextAlignment(alignment)
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 10)
            .animation(.easeOut(duration: 0.8).delay(0.55), value: hasAppeared)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
}

#Preview("iPhone Onboarding Supporting Note") {
    OnboardingIOSSupportingNote(
        text: "iPhone preview keeps the supporting-note component isolated for platform-specific layout debugging.",
        hasAppeared: true,
        alignment: .center,
        maxWidth: 360
    )
    .padding(32)
    .onboardingPreviewSurface(size: CGSize(width: 390, height: 180))
}
