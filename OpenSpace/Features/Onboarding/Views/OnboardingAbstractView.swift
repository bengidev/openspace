//
//  OnboardingAbstractView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingAbstractView: View {
    let variant: OnboardingPlatformVariant
    let context: OnboardingRenderContext
    let onContinue: () -> Void

    var body: some View {
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
