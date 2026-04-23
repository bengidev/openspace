//
//  OnboardingMacLayout.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct OnboardingMacLayout {
  let context: OnboardingRenderContext

  private var isCompactWidth: Bool {
    context.containerSize.width < 1120
  }

  private var isCompactHeight: Bool {
    context.containerSize.height < 680
  }

  var panelCornerRadius: CGFloat { 0 }
  var panelHorizontalPadding: CGFloat { 0 }
  var panelMaxWidth: CGFloat? { nil }

  var panelMinHeight: CGFloat {
    let preferredHeight = context.containerSize.height * (isCompactHeight ? 0.46 : 0.52)
    return min(max(isCompactHeight ? 432 : 468, preferredHeight), 560)
  }

  var panelTopPadding: CGFloat { isCompactHeight ? 14 : 22 }
  var panelBottomPadding: CGFloat { isCompactHeight ? 8 : 14 }
  var panelHorizontalInset: CGFloat { prefersStackedHero ? 18 : 24 }
  var sectionSpacing: CGFloat { prefersStackedHero ? 12 : 16 }
  var heroColumnSpacing: CGFloat { prefersStackedHero ? 18 : 28 }
  var heroContentSpacing: CGFloat { isCompactHeight ? 10 : 14 }
  var cardStackSpacing: CGFloat { isCompactHeight ? 10 : 14 }

  var prefersStackedHero: Bool { context.containerSize.width < 980 }
  var secondaryColumnWidth: CGFloat { min(max(context.containerSize.width * 0.28, 288), 360) }

  var titleTopPadding: CGFloat { prefersStackedHero ? 20 : 28 }
  var actionBottomPadding: CGFloat { isCompactHeight ? 20 : 28 }
  var footerTopPadding: CGFloat { isCompactHeight ? 10 : 14 }

  var heroTitleSize: CGFloat {
    if context.containerSize.width < 900 {
      30
    } else if context.containerSize.width < 1160 {
      34
    } else {
      38
    }
  }

  var heroSubtitleFont: Font { context.containerSize.width < 920 ? .body : .title3 }
  var heroTextMaxWidth: CGFloat? { prefersStackedHero ? nil : 560 }
  var heroSupportingTextMaxWidth: CGFloat? { prefersStackedHero ? nil : 540 }
  var heroPrimaryButtonFont: Font { .title3.weight(.semibold) }
  var heroPrimaryButtonMinWidth: CGFloat? { prefersStackedHero ? nil : 240 }
  var heroPrimaryButtonMinHeight: CGFloat { 50 }
  var heroPrimaryButtonHorizontalPadding: CGFloat { 28 }
  var heroPrimaryButtonVerticalPadding: CGFloat { 16 }

  var supportingNoteMaxWidth: CGFloat? { 860 }
}
