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
    switch variant {
    case .mac:
      let minimumHeight: CGFloat = usesStackedMacHero ? 428 : 452
      let preferredHeight = containerSize.height * (usesCondensedSpacing ? 0.46 : 0.5)
      return min(max(minimumHeight, preferredHeight), 548)
    case .ios, .ipad:
      let reservedHeight: CGFloat = usesCondensedSpacing ? 120 : 88
      let viewportDrivenHeight = max(420, containerSize.height - reservedHeight)
      return min(variant.panelMinHeight, viewportDrivenHeight)
    }
  }

  var topSectionSpacing: CGFloat {
    isCompactHeight ? 16 : 24
  }

  var heroSectionSpacing: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 14 : 18
    case .ios, .ipad:
      return usesCondensedSpacing ? 24 : 56
    }
  }

  var footerSectionSpacing: CGFloat {
    usesCondensedSpacing ? 16 : 28
  }

  var heroStackSpacing: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 12 : 16
    case .ios, .ipad:
      return usesCondensedSpacing ? 14 : 20
    }
  }

  var heroContentSpacing: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 8 : 12
    case .ios, .ipad:
      return usesCondensedSpacing ? 10 : 14
    }
  }

  var desktopPanelPadding: CGFloat {
    switch variant {
    case .mac:
      return usesStackedMacHero ? 18 : 24
    case .ios, .ipad:
      return 0
    }
  }

  var desktopSectionSpacing: CGFloat {
    switch variant {
    case .mac:
      return usesStackedMacHero ? 10 : 12
    case .ios, .ipad:
      return topSectionSpacing
    }
  }

  var desktopSidebarWidth: CGFloat {
    min(max(panelMaxWidth * 0.31, 340), 410)
  }

  var macSpacingAfterCapabilities: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 6 : 10
    case .ios, .ipad:
      return 0
    }
  }

  var macSpacingAfterHeroCopy: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 8 : 12
    case .ios, .ipad:
      return 0
    }
  }

  var macSpacingBeforeFooter: CGFloat {
    switch variant {
    case .mac:
      return usesCondensedSpacing ? 8 : 12
    case .ios, .ipad:
      return 0
    }
  }

  var heroTitleSize: CGFloat {
    switch variant {
    case .ios:
      containerSize.width < 390 ? 32 : 38
    case .ipad:
      containerSize.width < 900 ? 40 : 46
    case .mac:
      if containerSize.width < 860 {
        28
      } else if containerSize.width < 1080 {
        32
      } else {
        36
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
      680
    }
  }

  private var compactWidthThreshold: CGFloat {
    switch variant {
    case .ios:
      390
    case .ipad:
      820
    case .mac:
      1120
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
