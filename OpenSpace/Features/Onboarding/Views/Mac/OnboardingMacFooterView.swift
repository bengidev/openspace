//
//  OnboardingMacFooterView.swift
//  OpenSpace
//
//  macOS-focused onboarding view component.
//

import SwiftUI

// MARK: - OnboardingMacFooterView

struct OnboardingMacFooterView: View {
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
    OnboardingMacFooterView(
        labels: ["LOCAL-FIRST WORKBENCH", "DESKTOP DENSITY", "MULTI-WINDOW READY"],
        hasAppeared: true,
        alignment: .leading,
        identifierPrefix: "preview.onboarding.mac"
    )
    .padding(32)
    .onboardingComponentPreviewSurface()
}
