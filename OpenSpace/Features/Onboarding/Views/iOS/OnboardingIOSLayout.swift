//
//  OnboardingIOSLayout.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct OnboardingIOSLayout {
    // MARK: Internal

    let context: OnboardingRenderContext

    var panelCornerRadius: CGFloat {
        34
    }

    var panelHorizontalPadding: CGFloat {
        isCompactWidth ? 14 : 18
    }

    var panelMaxWidth: CGFloat? {
        460
    }

    var panelMinHeight: CGFloat {
        let reservedHeight: CGFloat = isCompactHeight ? 118 : 144
        let viewportDrivenHeight = max(520, context.containerSize.height - reservedHeight)
        return min(viewportDrivenHeight, 720)
    }

    var screenVerticalPadding: CGFloat {
        isCompactHeight ? 8 : 12
    }

    var screenTopSpacing: CGFloat {
        isCompactHeight ? 10 : 18
    }

    var screenStackSpacing: CGFloat {
        isCompactHeight ? 18 : 26
    }

    var screenContentMinHeight: CGFloat {
        max(context.containerSize.height - 16, 0)
    }

    var headerHorizontalPadding: CGFloat {
        isCompactWidth ? 18 : 22
    }

    var headerTopPadding: CGFloat {
        isCompactHeight ? 18 : 22
    }

    var capabilityTopPadding: CGFloat {
        isCompactHeight ? 16 : 22
    }

    var capabilityHorizontalPadding: CGFloat {
        isCompactWidth ? 18 : 22
    }

    var capabilitySpacing: CGFloat {
        isCompactWidth ? 8 : 10
    }

    var capabilityChipPadding: CGFloat {
        isCompactWidth ? 11 : 12
    }

    var heroHorizontalPadding: CGFloat {
        isCompactWidth ? 22 : 28
    }

    var heroTopPadding: CGFloat {
        isCompactHeight ? 16 : 24
    }

    var heroBottomPadding: CGFloat {
        isCompactHeight ? 18 : 28
    }

    var heroSignalHorizontalPadding: CGFloat {
        isCompactWidth ? 18 : 20
    }

    var heroTopSpacer: CGFloat {
        isCompactHeight ? 18 : 30
    }

    var heroBottomSpacer: CGFloat {
        isCompactHeight ? 20 : 34
    }

    var heroTextSpacing: CGFloat {
        isCompactHeight ? 10 : 14
    }

    var heroTitleSize: CGFloat {
        isCompactWidth ? 30 : 34
    }

    var heroSubtitleFont: Font {
        isCompactWidth ? .subheadline : .body
    }

    var heroTextMaxWidth: CGFloat? {
        isCompactWidth ? 286 : 332
    }

    var heroSupportingTextMaxWidth: CGFloat? {
        isCompactWidth ? 296 : 344
    }

    var heroPrimaryButtonFont: Font {
        .headline.weight(.semibold)
    }

    var heroPrimaryButtonMinHeight: CGFloat {
        isCompactHeight ? 42 : 44
    }

    var heroPrimaryButtonHorizontalPadding: CGFloat {
        isCompactWidth ? 22 : 24
    }

    var heroPrimaryButtonVerticalPadding: CGFloat {
        isCompactHeight ? 14 : 16
    }

    var footerTopSpacing: CGFloat {
        isCompactHeight ? 12 : 18
    }

    var footerHorizontalPadding: CGFloat {
        isCompactWidth ? 20 : 24
    }

    var footerBottomPadding: CGFloat {
        isCompactHeight ? 18 : 22
    }

    var supportingNoteMaxWidth: CGFloat? {
        isCompactHeight ? nil : 360
    }

    var supportingNoteHorizontalPadding: CGFloat {
        isCompactWidth ? 22 : 28
    }

    var supportingNoteBottomPadding: CGFloat {
        isCompactHeight ? 14 : 20
    }

    // MARK: Private

    private var isCompactWidth: Bool {
        context.containerSize.width < 390
    }

    private var isCompactHeight: Bool {
        context.containerSize.height < 760
    }
}
