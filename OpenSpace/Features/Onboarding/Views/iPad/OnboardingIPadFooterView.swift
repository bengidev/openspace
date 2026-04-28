//
//  OnboardingIPadFooterView.swift
//  OpenSpace
//
//  iPad-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingIPadFooterView

struct OnboardingIPadFooterView: View {
    let labels: [String]
    let hasAppeared: Bool
    let alignment: Alignment
    let identifierPrefix: String

    var body: some View {
        OnboardingMetadataBar(
            labels: labels,
            hasAppeared: hasAppeared,
            alignment: alignment,
            identifierPrefix: "\(identifierPrefix).footer"
        )
    }
}

#Preview("Onboarding Footer Component") {
    OnboardingIPadFooterView(
        labels: ["IPAD WORKSPACE", "EXPANSIVE COMPOSITION", "FOCUS + BREADTH"],
        hasAppeared: true,
        alignment: .center,
        identifierPrefix: "preview.onboarding.ipad"
    )
    .padding(32)
    .onboardingComponentPreviewSurface()
}
