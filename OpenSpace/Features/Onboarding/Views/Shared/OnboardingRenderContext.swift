//
//  OnboardingRenderContext.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingRenderContext {
  let variant: OnboardingPlatformVariant
  let capabilityChips: [String]
  let containerSize: CGSize
  let hasAppeared: Bool
  let reduceMotion: Bool

  var isAnimated: Bool {
    !reduceMotion && hasAppeared
  }

  var panelMaxWidth: CGFloat {
    let availableWidth = max(containerSize.width - (variant.panelHorizontalPadding * 2), 320)
    return min(variant.panelMaxWidth, availableWidth)
  }

  var panelMinHeight: CGFloat {
    let reservedHeight: CGFloat = usesCondensedSpacing ? 120 : 88
    let viewportDrivenHeight = max(420, containerSize.height - reservedHeight)
    return min(variant.panelMinHeight, viewportDrivenHeight)
  }

  var topSectionSpacing: CGFloat {
    isCompactHeight ? 28 : 44
  }

  var heroSectionSpacing: CGFloat {
    usesCondensedSpacing ? 52 : 104
  }

  var footerSectionSpacing: CGFloat {
    usesCondensedSpacing ? 28 : 52
  }

  var heroStackSpacing: CGFloat {
    usesCondensedSpacing ? 18 : 28
  }

  var heroContentSpacing: CGFloat {
    usesCondensedSpacing ? 14 : 18
  }

  var heroTitleSize: CGFloat {
    switch variant {
    case .ios:
      containerSize.width < 390 ? 32 : 38
    case .ipad:
      containerSize.width < 900 ? 40 : 46
    case .mac:
      if containerSize.width < 860 {
        34
      } else if containerSize.width < 1080 {
        42
      } else {
        48
      }
    }
  }

  var heroSubtitleFont: Font {
    switch variant {
    case .ios:
      return .subheadline
    case .ipad:
      return containerSize.width < 900 ? .body : .title3
    case .mac:
      return containerSize.width < 860 ? .body : .title3
    }
  }

  var heroTextMaxWidth: CGFloat? {
    switch variant {
    case .ios:
      return 520
    case .ipad:
      return containerSize.width < 900 ? 620 : 760
    case .mac:
      return usesStackedMacHero ? nil : 560
    }
  }

  var heroSupportingTextMaxWidth: CGFloat? {
    switch variant {
    case .ios:
      return 520
    case .ipad:
      return containerSize.width < 900 ? 600 : 700
    case .mac:
      return usesStackedMacHero ? nil : 560
    }
  }

  var supportingNoteMaxWidth: CGFloat? {
    usesCondensedSpacing ? nil : defaultSupportingNoteMaxWidth
  }

  var usesStackedMacHero: Bool {
    switch variant {
    case .mac:
      return panelMaxWidth < 920
    case .ios, .ipad:
      return false
    }
  }

  private var usesCondensedSpacing: Bool {
    isCompactHeight || panelMaxWidth < compactWidthThreshold
  }

  private var isCompactHeight: Bool {
    containerSize.height < compactHeightThreshold
  }

  private var compactHeightThreshold: CGFloat {
    switch variant {
    case .ios:
      760
    case .ipad:
      820
    case .mac:
      760
    }
  }

  private var compactWidthThreshold: CGFloat {
    switch variant {
    case .ios:
      390
    case .ipad:
      820
    case .mac:
      980
    }
  }

  private var defaultSupportingNoteMaxWidth: CGFloat {
    switch variant {
    case .ios:
      620
    case .ipad:
      760
    case .mac:
      840
    }
  }
}
