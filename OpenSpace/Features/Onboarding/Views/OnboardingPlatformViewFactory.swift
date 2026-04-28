//
//  OnboardingPlatformViewFactory.swift
//  OpenSpace
//
//  Abstract-factory facade for selecting platform-owned onboarding views.
//

import SwiftUI

enum OnboardingPlatformViewFactory {
    @ViewBuilder
    static func makeContent(
        for variant: OnboardingPlatformVariant,
        context: OnboardingRenderContext,
        onContinue: @escaping () -> Void
    ) -> some View {
        switch variant {
        case .ios:
            OnboardingIOSView(context: context, onContinue: onContinue)
        case .ipad:
            OnboardingIPadView(context: context, onContinue: onContinue)
        case .mac:
            OnboardingMacView(context: context, onContinue: onContinue)
        }
    }
}
