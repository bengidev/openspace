import SwiftUI

protocol WorkspaceLayoutProfile {
  var containerSize: CGSize { get }

  var shellMaxWidth: CGFloat { get }
  var shellHorizontalPadding: CGFloat { get }
  var shellVerticalPadding: CGFloat { get }
  var shellCornerRadius: CGFloat { get }
  var sidebarWidth: CGFloat { get }
  var usesSidebar: Bool { get }
  var mainSectionSpacing: CGFloat { get }
  var heroTitleFont: Font { get }
  var heroCopyMaxWidth: CGFloat { get }
  var composerMaxWidth: CGFloat { get }
  var quickPromptMaxWidth: CGFloat { get }
  var heroTopSpacing: CGFloat { get }
  var heroSectionSpacing: CGFloat { get }
  var exampleGridMinWidth: CGFloat { get }
  var contentTopBarSpacing: CGFloat { get }
  var mainHorizontalPadding: CGFloat { get }
  var mainVerticalPadding: CGFloat { get }
  var railItemSpacing: CGFloat { get }
}

extension WorkspaceLayoutProfile {
  var preferredShellHeight: CGFloat { 820 }
  var minimumShellHeight: CGFloat {
    max(containerSize.height - (shellVerticalPadding * 2), preferredShellHeight)
  }
}

struct IOSLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize

  var shellMaxWidth: CGFloat { 760 }
  var shellHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.038, 16), 22)
  }
  var shellVerticalPadding: CGFloat { 14 }
  var shellCornerRadius: CGFloat { 30 }
  var sidebarWidth: CGFloat { 0 }
  var usesSidebar: Bool { false }
  var mainSectionSpacing: CGFloat { 22 }
  var heroTitleFont: Font { .system(size: 36, weight: .semibold) }
  var heroCopyMaxWidth: CGFloat { 440 }
  var composerMaxWidth: CGFloat { 560 }
  var quickPromptMaxWidth: CGFloat { 580 }
  var heroTopSpacing: CGFloat { 20 }
  var heroSectionSpacing: CGFloat { 18 }
  var exampleGridMinWidth: CGFloat { 160 }
  var contentTopBarSpacing: CGFloat { 12 }
  var mainHorizontalPadding: CGFloat { 18 }
  var mainVerticalPadding: CGFloat { 18 }
  var railItemSpacing: CGFloat { 0 }
}

struct IPadLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize

  var shellMaxWidth: CGFloat { 1380 }
  var shellHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.03, 18), 32)
  }
  var shellVerticalPadding: CGFloat { usesSidebar ? 18 : 16 }
  var shellCornerRadius: CGFloat { 36 }
  var sidebarWidth: CGFloat { 88 }
  var usesSidebar: Bool { containerSize.width >= 900 }
  var mainSectionSpacing: CGFloat { 28 }
  var heroTitleFont: Font { .system(size: 52, weight: .semibold) }
  var heroCopyMaxWidth: CGFloat { 620 }
  var composerMaxWidth: CGFloat { 780 }
  var quickPromptMaxWidth: CGFloat { 860 }
  var heroTopSpacing: CGFloat { 34 }
  var heroSectionSpacing: CGFloat { 22 }
  var exampleGridMinWidth: CGFloat { 160 }
  var contentTopBarSpacing: CGFloat { 18 }
  var mainHorizontalPadding: CGFloat { 28 }
  var mainVerticalPadding: CGFloat { 24 }
  var railItemSpacing: CGFloat { usesSidebar ? 8 : 0 }
}

struct MacLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize

  var shellMaxWidth: CGFloat { .infinity }
  var shellHorizontalPadding: CGFloat { 0 }
  var shellVerticalPadding: CGFloat { 0 }
  var shellCornerRadius: CGFloat { 0 }
  var sidebarWidth: CGFloat { 72 }
  var usesSidebar: Bool { true }
  var mainSectionSpacing: CGFloat { 24 }
  var heroTitleFont: Font { .system(size: 46, weight: .semibold) }
  var heroCopyMaxWidth: CGFloat { 560 }
  var composerMaxWidth: CGFloat { 720 }
  var quickPromptMaxWidth: CGFloat { 760 }
  var heroTopSpacing: CGFloat { 22 }
  var heroSectionSpacing: CGFloat { 18 }
  var exampleGridMinWidth: CGFloat { 156 }
  var contentTopBarSpacing: CGFloat { 16 }
  var mainHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.018, 26), 48)
  }
  var mainVerticalPadding: CGFloat { 22 }
  var railItemSpacing: CGFloat { 8 }
}
