//
//  OnboardingPlatformVariant.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

enum OnboardingPlatformVariant {
  case ios
  case ipad
  case mac

  var identifierPrefix: String {
    switch self {
    case .ios:
      "onboarding.ios"
    case .ipad:
      "onboarding.ipad"
    case .mac:
      "onboarding.mac"
    }
  }

  var panelStyle: OnboardingHeroPanelStyle {
    switch self {
    case .mac:
      .desktopCanvas
    case .ios, .ipad:
      .floatingShowcase
    }
  }

  var usesFloatingPanelEffect: Bool {
    switch self {
    case .mac:
      false
    case .ios, .ipad:
      true
    }
  }
}
