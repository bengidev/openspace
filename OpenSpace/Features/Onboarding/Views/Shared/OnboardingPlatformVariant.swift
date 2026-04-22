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

  var panelCornerRadius: CGFloat {
    switch self {
    case .ios:
      34
    case .ipad:
      38
    case .mac:
      0
    }
  }

  var panelMaxWidth: CGFloat {
    switch self {
    case .ios:
      820
    case .ipad:
      980
    case .mac:
      .infinity
    }
  }

  var panelMinHeight: CGFloat {
    switch self {
    case .ios:
      600
    case .ipad:
      680
    case .mac:
      460
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

  var panelHorizontalPadding: CGFloat {
    switch self {
    case .mac:
      0
    case .ios, .ipad:
      18
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
