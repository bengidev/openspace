//
//  OnboardingPlatformVariant.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

enum OnboardingPlatformVariant {
    case ios
    case ipad

    var identifierPrefix: String {
        switch self {
        case .ios:
            "onboarding.ios"
        case .ipad:
            "onboarding.ipad"
        }
    }
}
