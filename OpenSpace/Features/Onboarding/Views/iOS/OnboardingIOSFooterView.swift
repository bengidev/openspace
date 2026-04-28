//
//  OnboardingIOSFooterView.swift
//  OpenSpace
//
//  iPhone-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingIOSFooterView

struct OnboardingIOSFooterView: View {
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

#Preview("iPhone Onboarding Footer") {
    OnboardingIOSFooterView(
        labels: ["FIRST-RUN ONBOARDING", "FUTURISTIC CALM", "LOCAL-FIRST"],
        hasAppeared: true,
        alignment: .center,
        identifierPrefix: "preview.onboarding.ios"
    )
    .padding(32)
    .onboardingPreviewSurface(size: CGSize(width: 390, height: 160))
}
