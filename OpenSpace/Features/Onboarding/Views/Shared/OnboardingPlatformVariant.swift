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

  var panelCornerRadius: CGFloat {
    switch self {
    case .ios:
      34
    case .ipad:
      38
    case .mac:
      40
    }
  }

  var panelMaxWidth: CGFloat {
    switch self {
    case .ios:
      820
    case .ipad:
      980
    case .mac:
      1080
    }
  }

  var panelMinHeight: CGFloat {
    switch self {
    case .ios:
      600
    case .ipad:
      680
    case .mac:
      640
    }
  }
}
