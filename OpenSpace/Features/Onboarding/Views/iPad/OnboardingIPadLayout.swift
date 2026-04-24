//
//  OnboardingIPadLayout.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct OnboardingIPadLayout {
    // MARK: Internal

    let context: OnboardingRenderContext

    var panelCornerRadius: CGFloat {
        40
    }

    var panelHorizontalPadding: CGFloat {
        isCompactWidth ? 22 : 32
    }

    var panelMaxWidth: CGFloat? {
        isCompactWidth ? 960 : 1080
    }

    var panelMinHeight: CGFloat {
        let reservedHeight: CGFloat = isCompactHeight ? 108 : 136
        let viewportDrivenHeight = max(700, context.containerSize.height - reservedHeight)
        return min(viewportDrivenHeight, 980)
    }

    var screenVerticalPadding: CGFloat {
        isCompactHeight ? 10 : 18
    }

    var screenTopSpacing: CGFloat {
        isCompactHeight ? 12 : 22
    }

    var screenStackSpacing: CGFloat {
        isCompactHeight ? 24 : 32
    }

    var screenContentMinHeight: CGFloat {
        max(context.containerSize.height - 24, 0)
    }

    var headerHorizontalPadding: CGFloat {
        isCompactWidth ? 26 : 34
    }

    var headerTopPadding: CGFloat {
        isCompactHeight ? 24 : 30
    }

    var capabilityTopSpacing: CGFloat {
        isCompactHeight ? 10 : 12
    }

    var capabilityHorizontalPadding: CGFloat {
        isCompactWidth ? 26 : 34
    }

    var capabilitySpacing: CGFloat {
        isCompactWidth ? 10 : 12
    }

    var capabilityChipPadding: CGFloat {
        isCompactWidth ? 14 : 16
    }

    var heroTopSpacing: CGFloat {
        isCompactHeight ? 6 : 8
    }

    var heroHorizontalPadding: CGFloat {
        isCompactWidth ? 28 : 42
    }

    var heroBottomPadding: CGFloat {
        isCompactHeight ? 14 : 16
    }

    var heroColumnSpacing: CGFloat {
        isCompactWidth ? 16 : 20
    }

    var heroCopySpacing: CGFloat {
        isCompactHeight ? 14 : 16
    }

    var heroTextBlockSpacing: CGFloat {
        isCompactHeight ? 14 : 16
    }

    var heroActionTopSpacing: CGFloat {
        isCompactHeight ? 18 : 20
    }

    var heroCardSpacing: CGFloat {
        isCompactHeight ? 12 : 14
    }

    var heroCardInternalSpacing: CGFloat {
        isCompactHeight ? 10 : 12
    }

    var prefersStackedHero: Bool {
        context.containerSize.width < 980
    }

    var heroCopyColumnMaxWidth: CGFloat? {
        prefersStackedHero ? 600 : 500
    }

    var heroCardColumnWidth: CGFloat? {
        prefersStackedHero ? nil : 280
    }

    var heroTitleSize: CGFloat {
        prefersStackedHero ? 32 : 36
    }

    var heroSubtitleFont: Font {
        prefersStackedHero ? .callout : .body
    }

    var heroTextMaxWidth: CGFloat? {
        prefersStackedHero ? 560 : 460
    }

    var heroSupportingTextMaxWidth: CGFloat? {
        prefersStackedHero ? 540 : 480
    }

    var heroPrimaryButtonFont: Font {
        .subheadline.weight(.semibold)
    }

    var heroPrimaryButtonMinHeight: CGFloat {
        40
    }

    var heroPrimaryButtonHorizontalPadding: CGFloat {
        prefersStackedHero ? 22 : 26
    }

    var heroPrimaryButtonVerticalPadding: CGFloat {
        14
    }

    var footerTopSpacing: CGFloat {
        isCompactHeight ? 12 : 14
    }

    var footerHorizontalPadding: CGFloat {
        isCompactWidth ? 28 : 34
    }

    var footerBottomPadding: CGFloat {
        isCompactHeight ? 20 : 24
    }

    var supportingNoteMaxWidth: CGFloat? {
        prefersStackedHero ? 680 : 820
    }

    var supportingNoteHorizontalPadding: CGFloat {
        isCompactWidth ? 28 : 36
    }

    var supportingNoteBottomPadding: CGFloat {
        isCompactHeight ? 18 : 24
    }

    // MARK: Private

    private var isCompactWidth: Bool {
        context.containerSize.width < 880
    }

    private var isCompactHeight: Bool {
        context.containerSize.height < 980
    }
}
