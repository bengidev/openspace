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
    context.containerSize.width < 1080
  }

  private var isCompactHeight: Bool {
    context.containerSize.height < 720
  }

  private var isExpandedHeight: Bool {
    context.containerSize.height > 900
  }

  var panelCornerRadius: CGFloat { 0 }
  var panelHorizontalPadding: CGFloat { 0 }
  var panelMaxWidth: CGFloat? { nil }
  var contentMaxWidth: CGFloat? {
    guard !isCompactWidth else { return nil }
    return min(context.containerSize.width - 56, isExpandedHeight ? 1440 : 1320)
  }

  var panelMinHeight: CGFloat {
    let preferredHeight = context.containerSize.height - (screenVerticalPadding * 2)
    return max(isCompactHeight ? 520 : 600, preferredHeight)
  }

  var screenVerticalPadding: CGFloat { 0 }
  var screenTopSpacing: CGFloat { 0 }
  var screenContentMinHeight: CGFloat { max(context.containerSize.height - (screenVerticalPadding * 2), 0) }

  var panelTopPadding: CGFloat { isCompactHeight ? 16 : (isExpandedHeight ? 34 : 22) }
  var panelBottomPadding: CGFloat { isCompactHeight ? 16 : (isExpandedHeight ? 28 : 22) }
  var panelHorizontalInset: CGFloat { isCompactWidth ? 18 : (isExpandedHeight ? 32 : 24) }
  var sectionSpacing: CGFloat { prefersStackedHero ? 12 : 16 }
  var heroColumnSpacing: CGFloat { prefersStackedHero ? 18 : 28 }
  var heroContentSpacing: CGFloat { isCompactHeight ? 10 : 14 }
  var cardStackSpacing: CGFloat { isCompactHeight ? 10 : 14 }

  var prefersStackedHero: Bool { context.containerSize.width < 980 }
  var secondaryColumnWidth: CGFloat { min(max(context.containerSize.width * 0.24, 300), 360) }

  var titleTopPadding: CGFloat { prefersStackedHero ? 16 : 22 }
  var actionTopPadding: CGFloat { isCompactHeight ? 34 : (isExpandedHeight ? 72 : 56) }
  var actionBottomPadding: CGFloat { isCompactHeight ? 4 : 8 }
  var footerTopPadding: CGFloat { isCompactHeight ? 10 : 14 }

  var heroTitleSize: CGFloat {
    if isCompactHeight || context.containerSize.width < 900 {
      28
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
