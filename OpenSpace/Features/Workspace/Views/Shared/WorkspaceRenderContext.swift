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
      containerSize.width >= 920
    case .mac:
      true
    }
  }

  var shellMaxWidth: CGFloat {
    switch variant {
    case .ios:
      760
    case .ipad:
      1320
    case .mac:
      1320
    }
  }

  var shellHorizontalPadding: CGFloat {
    switch variant {
    case .ios:
      min(max(containerSize.width * 0.038, 18), 24)
    case .ipad:
      min(max(containerSize.width * 0.034, 22), 40)
    case .mac:
      0
    }
  }

  var shellVerticalPadding: CGFloat {
    switch variant {
    case .ios:
      18
    case .ipad:
      usesSidebar ? 28 : 20
    case .mac:
      0
    }
  }

  var shellCornerRadius: CGFloat {
    switch variant {
    case .ios:
      34
    case .ipad:
      34
    case .mac:
      30
    }
  }

  var minimumShellHeight: CGFloat {
    max(containerSize.height - (shellVerticalPadding * 2), preferredShellHeight)
  }

  var preferredShellHeight: CGFloat {
    switch variant {
    case .ios:
      680
    case .ipad:
      760
    case .mac:
      736
    }
  }

  var sidebarWidth: CGFloat {
    switch variant {
    case .ios:
      0
    case .ipad:
      236
    case .mac:
      248
    }
  }

  var mainSectionSpacing: CGFloat {
    switch variant {
    case .mac:
      24
    case .ios, .ipad:
      usesSidebar ? 34 : 24
    }
  }

  var heroTitleFont: Font {
    switch variant {
    case .ios:
      .title2.weight(.semibold)
    case .ipad:
      .system(size: 34, weight: .semibold)
    case .mac:
      .system(size: 38, weight: .semibold)
    }
  }

  var heroCopyMaxWidth: CGFloat {
    usesSidebar ? 500 : 460
  }

  var composerMaxWidth: CGFloat {
    usesSidebar ? 640 : 560
  }

  var quickPromptMaxWidth: CGFloat {
    usesSidebar ? 720 : 600
  }

  var mainHorizontalPadding: CGFloat {
    switch variant {
    case .mac:
      34
    case .ios, .ipad:
      usesSidebar ? 28 : 18
    }
  }

  var mainVerticalPadding: CGFloat {
    switch variant {
    case .mac:
      28
    case .ios, .ipad:
      usesSidebar ? 22 : 18
    }
  }

  var idealWindowSize: CGSize {
    switch variant {
    case .ios:
      CGSize(width: 390, height: 844)
    case .ipad:
      CGSize(width: 1024, height: 760)
    case .mac:
      CGSize(width: 1280, height: 820)
    }
  }

  var minimumWindowSize: CGSize {
    switch variant {
    case .ios:
      CGSize(width: 390, height: 844)
    case .ipad:
      CGSize(width: 920, height: 700)
    case .mac:
      CGSize(width: 1180, height: 740)
    }
  }
}
