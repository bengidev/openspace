//
//  WorkspaceRenderContext.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceRenderContext {
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
      containerSize.width >= 900
    case .mac:
      true
    }
  }

  var shellMaxWidth: CGFloat {
    switch variant {
    case .ios:
      760
    case .ipad:
      1380
    case .mac:
      1440
    }
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
    max(containerSize.height - (shellVerticalPadding * 2), preferredShellHeight)
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
      24
    }
  }

  var heroTitleFont: Font {
    switch variant {
    case .ios:
      .system(size: 36, weight: .semibold, design: .default)
    case .ipad:
      .system(size: 52, weight: .semibold, design: .default)
    case .mac:
      .system(size: 46, weight: .semibold, design: .default)
    }
  }

  var heroCopyMaxWidth: CGFloat {
    switch variant {
    case .ios:
      440
    case .ipad:
      620
    case .mac:
      560
    }
  }

  var composerMaxWidth: CGFloat {
    switch variant {
    case .ios:
      560
    case .ipad:
      780
    case .mac:
      720
    }
  }

  var quickPromptMaxWidth: CGFloat {
    switch variant {
    case .ios:
      580
    case .ipad:
      860
    case .mac:
      760
    }
  }

  var railItemSpacing: CGFloat {
    usesSidebar ? 8 : 0
  }

  var heroTopSpacing: CGFloat {
    switch variant {
    case .ios:
      20
    case .ipad:
      34
    case .mac:
      22
    }
  }

  var heroSectionSpacing: CGFloat {
    switch variant {
    case .ios:
      18
    case .ipad:
      22
    case .mac:
      18
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
      26
    case .ipad:
      28
    case .ios:
      18
    }
  }

  var mainVerticalPadding: CGFloat {
    switch variant {
    case .mac:
      22
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
}
