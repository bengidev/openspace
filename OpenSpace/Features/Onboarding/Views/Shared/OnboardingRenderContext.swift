//
//  OnboardingRenderContext.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingRenderContext {
    let capabilityChips: [String]
    let containerSize: CGSize
    let hasAppeared: Bool
    let reduceMotion: Bool

    var isAnimated: Bool {
        !reduceMotion && hasAppeared
    }
}
