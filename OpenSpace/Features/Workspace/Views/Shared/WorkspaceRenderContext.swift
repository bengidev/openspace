//
//  WorkspaceRenderContext.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceRenderContext {
    // MARK: Internal

    let variant: WorkspacePlatformVariant
    let containerSize: CGSize
    let hasAppeared: Bool
    let reduceMotion: Bool

    var isAnimated: Bool {
        !reduceMotion && hasAppeared
    }

    var usesSidebar: Bool {
        switch variant {
        case .ios:
            false
        case .ipad:
            false
        case .mac:
            false
        }
    }

    var shellMaxWidth: CGFloat {
        switch variant {
        case .ios:
            760
        case .ipad:
            1380
        case .mac:
            .infinity
        }
    }

    var shellWidth: CGFloat {
        min(
            shellMaxWidth,
            max(containerSize.width - (shellHorizontalPadding * 2), 0)
        )
    }

    var shellHorizontalPadding: CGFloat {
        switch variant {
        case .ios:
            min(max(containerSize.width * 0.038, 16), 22)
        case .ipad:
            min(max(containerSize.width * 0.03, 18), 32)
        case .mac:
            0
        }
    }

    var shellVerticalPadding: CGFloat {
        switch variant {
        case .ios:
            14
        case .ipad:
            usesSidebar ? 18 : 16
        case .mac:
            0
        }
    }

    var shellCornerRadius: CGFloat {
        switch variant {
        case .ios:
            30
        case .ipad:
            36
        case .mac:
            0
        }
    }

    var minimumShellHeight: CGFloat {
        switch variant {
        case .ios, .ipad:
            max(containerSize.height - (shellVerticalPadding * 2), preferredShellHeight)
        case .mac:
            max(containerSize.height - (shellVerticalPadding * 2), 0)
        }
    }

    var preferredShellHeight: CGFloat {
        switch variant {
        case .ios:
            720
        case .ipad:
            820
        case .mac:
            820
        }
    }

    var sidebarWidth: CGFloat {
        switch variant {
        case .ios:
            0
        case .ipad:
            88
        case .mac:
            72
        }
    }

    var mainSectionSpacing: CGFloat {
        switch variant {
        case .ios:
            22
        case .ipad:
            28
        case .mac:
            macUsesCompactVerticalLayout ? 14 : 24
        }
    }

    var heroTitleFont: Font {
        switch variant {
        case .ios:
            .system(
                size: min(max(containerSize.width * 0.074, 26), 30),
                weight: .semibold,
                design: .default
            )

        case .ipad:
            .system(size: 52, weight: .semibold, design: .default)

        case .mac:
            .system(
                size: min(max(min(containerSize.width * 0.04, containerSize.height * 0.06), 30), 46),
                weight: .semibold,
                design: .default
            )
        }
    }

    var heroTitleMinimumScaleFactor: CGFloat {
        variant == .ios ? 0.64 : 0.8
    }

    var heroCopyMaxWidth: CGFloat {
        switch variant {
        case .ios:
            min(containerSize.width - 72, 360)
        case .ipad:
            620
        case .mac:
            min(max(containerSize.width * 0.26, 560), 700)
        }
    }

    var composerMaxWidth: CGFloat {
        switch variant {
        case .ios:
            min(containerSize.width - 64, 360)
        case .ipad:
            780
        case .mac:
            min(max(containerSize.width * 0.42, 720), 980)
        }
    }

    var quickPromptMaxWidth: CGFloat {
        switch variant {
        case .ios:
            min(containerSize.width - 64, 360)
        case .ipad:
            860
        case .mac:
            min(max(containerSize.width * 0.44, 760), 1060)
        }
    }

    var workspaceContentMaxWidth: CGFloat {
        max(composerMaxWidth, quickPromptMaxWidth)
    }

    var railItemSpacing: CGFloat {
        usesSidebar ? 8 : 0
    }

    var heroTopSpacing: CGFloat {
        switch variant {
        case .ios:
            10
        case .ipad:
            34
        case .mac:
            macUsesCompactVerticalLayout ? 10 : min(max(containerSize.height * 0.045, 22), 58)
        }
    }

    var heroSectionSpacing: CGFloat {
        switch variant {
        case .ios:
            14
        case .ipad:
            22
        case .mac:
            macUsesCompactVerticalLayout ? 12 : 18
        }
    }

    var exampleGridMinWidth: CGFloat {
        switch variant {
        case .ios:
            160
        case .ipad:
            160
        case .mac:
            156
        }
    }

    var contentTopBarSpacing: CGFloat {
        switch variant {
        case .ios:
            12
        case .ipad:
            18
        case .mac:
            16
        }
    }

    var mainHorizontalPadding: CGFloat {
        switch variant {
        case .mac:
            min(max(containerSize.width * 0.018, 26), 48)
        case .ipad:
            28
        case .ios:
            20
        }
    }

    var mainVerticalPadding: CGFloat {
        switch variant {
        case .mac:
            macUsesCompactVerticalLayout ? 16 : min(max(containerSize.height * 0.024, 22), 44)
        case .ipad:
            24
        case .ios:
            18
        }
    }

    var idealWindowSize: CGSize {
        switch variant {
        case .ios:
            CGSize(width: 390, height: 844)
        case .ipad:
            CGSize(width: 1180, height: 860)
        case .mac:
            CGSize(width: 1400, height: 860)
        }
    }

    var minimumWindowSize: CGSize {
        switch variant {
        case .ios:
            CGSize(width: 390, height: 844)
        case .ipad:
            CGSize(width: 900, height: 720)
        case .mac:
            CGSize(width: 1200, height: 760)
        }
    }

    var heroOrbSize: CGFloat {
        switch variant {
        case .ios:
            48
        case .ipad:
            usesSidebar ? 66 : 56
        case .mac:
            macUsesCompactVerticalLayout ? 38 : min(max(containerSize.height * 0.065, 40), 54)
        }
    }

    var composerVStackSpacing: CGFloat {
        switch variant {
        case .ios:
            16
        case .ipad:
            usesSidebar ? 20 : 16
        case .mac:
            macUsesCompactVerticalLayout ? 12 : 20
        }
    }

    var composerTextFont: Font {
        switch variant {
        case .ios:
            .body
        case .ipad:
            .title3
        case .mac:
            macUsesCompactVerticalLayout ? .body : .title3
        }
    }

    var composerMinHeight: CGFloat {
        switch variant {
        case .ios:
            96
        case .ipad:
            usesSidebar ? 132 : 110
        case .mac:
            macUsesCompactVerticalLayout ? 78 : 104
        }
    }

    var composerLineLimit: ClosedRange<Int> {
        switch variant {
        case .ios:
            4 ... 6
        case .ipad:
            usesSidebar ? 4 ... 8 : 4 ... 6
        case .mac:
            4 ... 8
        }
    }

    var composerPadding: CGFloat {
        switch variant {
        case .ios:
            16
        case .ipad:
            usesSidebar ? 22 : 18
        case .mac:
            macUsesCompactVerticalLayout ? 12 : 18
        }
    }

    var composerCornerRadius: CGFloat {
        switch variant {
        case .ios, .ipad:
            26
        case .mac:
            22
        }
    }

    var composerUsesCompactFallback: Bool {
        variant == .ios
    }

    var toggleScale: CGFloat {
        switch variant {
        case .ios:
            0.72
        case .ipad, .mac:
            0.84
        }
    }

    var citationToggleFont: Font {
        switch variant {
        case .ios:
            .footnote.weight(.semibold)
        case .ipad, .mac:
            .subheadline.weight(.medium)
        }
    }

    var citationToggleSpacing: CGFloat {
        variant == .ios ? 4 : 8
    }

    var composerControlFont: Font {
        switch variant {
        case .ios:
            .callout.weight(.medium)
        case .ipad, .mac:
            .subheadline.weight(.medium)
        }
    }

    var composerControlIconSize: CGFloat {
        variant == .ios ? 12 : 13
    }

    var composerControlHorizontalPadding: CGFloat {
        variant == .ios ? 10 : 14
    }

    var composerControlVerticalPadding: CGFloat {
        variant == .ios ? 9 : 10
    }

    var sendButtonSize: CGFloat {
        variant == .ios ? 40 : 42
    }

    var quickPromptMinHeight: CGFloat {
        switch variant {
        case .ios:
            116
        case .mac:
            macUsesCompactVerticalLayout ? 96 : 128
        case .ipad:
            154
        }
    }

    var quickPromptPadding: CGFloat {
        switch variant {
        case .ios:
            16
        case .ipad:
            18
        case .mac:
            macUsesCompactVerticalLayout ? 14 : 16
        }
    }

    var quickPromptGridMinWidth: CGFloat {
        switch variant {
        case .ios, .ipad:
            160
        case .mac:
            156
        }
    }

    var utilityBarShowsInvite: Bool {
        false
    }

    var utilityBarSearchIsTextButton: Bool {
        false
    }

    var utilityBarButtonHorizontalPadding: CGFloat {
        switch variant {
        case .ios:
            17
        case .ipad, .mac:
            16
        }
    }

    var utilityBarButtonVerticalPadding: CGFloat {
        switch variant {
        case .ios:
            11
        case .ipad, .mac:
            12
        }
    }

    var heroHeadingSpacing: CGFloat {
        switch variant {
        case .ios:
            4
        case .ipad, .mac:
            2
        }
    }

    var heroHeadingMaxWidth: CGFloat? {
        switch variant {
        case .mac:
            900
        default:
            nil
        }
    }

    var compactNavBottomPadding: CGFloat {
        2
    }

    var compactNavItemSpacing: CGFloat {
        8
    }

    var compactNavHorizontalPadding: CGFloat {
        12
    }

    var compactNavVerticalPadding: CGFloat {
        10
    }

    var previewWidth: CGFloat {
        switch variant {
        case .ios:
            390
        case .ipad:
            920
        case .mac:
            1160
        }
    }

    var previewHeight: CGFloat {
        switch variant {
        case .ios:
            844
        case .ipad, .mac:
            820
        }
    }

    static func currentPlatform(
        containerSize: CGSize,
        hasAppeared: Bool,
        reduceMotion: Bool
    ) -> WorkspaceRenderContext {
        WorkspaceRenderContext(
            variant: .current,
            containerSize: containerSize,
            hasAppeared: hasAppeared,
            reduceMotion: reduceMotion
        )
    }

    func heroBodyFont(for _: WorkspaceDestination) -> Font {
        switch variant {
        case .ios:
            .body
        case .ipad:
            usesSidebar ? .title3.weight(.regular) : .body
        case .mac:
            .body
        }
    }

    // MARK: Private

    private var macUsesCompactVerticalLayout: Bool {
        variant == .mac && containerSize.height < 760
    }
}
