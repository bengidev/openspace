# OpenSpace Refactoring Plan

> Derived from code smell analysis in `code-smell-analysis.md`
> Reference: https://refactoring.guru/refactoring/catalog

---

## Goal

Eliminate monolith patterns, remove dead dependencies, and collapse speculative platform abstractions into a single adaptive layout system suitable for the current prototype scope.

---

## Phase 1: Remove Dead Code (Immediate)

**Pattern:** Remove Dead Dependency

### Step 1.1: Remove ComposableArchitecture from project

In Xcode:
1. Select project -> Package Dependencies
2. Remove `swift-composable-architecture`
3. Delete line 9 from `OpenSpace/App/OpenSpaceApp.swift`:

```swift
// REMOVE THIS LINE:
import ComposableArchitecture
```

### Step 1.2: Verify build

```bash
cd /path/to/OpenSpace
xcodebuild -project OpenSpace.xcodeproj -scheme OpenSpace -destination 'platform=iOS Simulator,name=iPhone 16' clean build
```

**Expected result:** Build succeeds with significantly fewer modules.

---

## Phase 2: Extract Unified Components (Week 1)

**Pattern:** Extract Method, Pull Up Method, Replace Conditional with Polymorphism

### Step 2.1: Create `WorkspaceLayoutProfile` protocol

**New file:** `OpenSpace/Shared/Layout/WorkspaceLayoutProfile.swift`

```swift
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
}

extension WorkspaceLayoutProfile {
  var preferredShellHeight: CGFloat { 820 }
  var minimumShellHeight: CGFloat {
    max(containerSize.height - (shellVerticalPadding * 2), preferredShellHeight)
  }
  var railItemSpacing: CGFloat { usesSidebar ? 8 : 0 }
}
```

### Step 2.2: Create platform profile implementations

**New file:** `OpenSpace/Shared/Layout/PlatformProfiles.swift`

```swift
import SwiftUI

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
}

struct MacLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize

  var shellMaxWidth: CGFloat { 1440 }
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
  var mainHorizontalPadding: CGFloat { 26 }
  var mainVerticalPadding: CGFloat { 22 }
}
```

### Step 2.3: Create `WorkspaceState` (@Observable)

**New file:** `OpenSpace/Features/Workspace/WorkspaceState.swift`

```swift
import SwiftUI
import Observation

@Observable
final class WorkspaceState {
  var selectedDestination: WorkspaceDestination = .home
  var selectedModel: WorkspaceModel = .chatGPT4o
  var selectedPrompt: String = ""
  var selectedWritingStyle: WorkspaceWritingStyle = .balanced
  var citationEnabled: Bool = true
  var highlightedQuickPrompt: WorkspaceQuickPrompt?
  var isPromptFocused: Bool = false
  var hasAppeared: Bool = false

  var replayOnboarding: () -> Void = {}

  #if os(macOS)
  var hasConfiguredWindow: Bool = false
  #endif
}
```

> Note: Requires iOS 17+. If targeting iOS 16, use `@StateObject` with `ObservableObject` instead.

### Step 2.4: Create unified `WorkspaceContentView`

**New file:** `OpenSpace/Features/Workspace/WorkspaceContentView.swift`

Replaces: `WorkspaceIOSContentViews.swift`, `WorkspaceMacContentViews.swift`, `WorkspaceIPadContentViews.swift`

```swift
import SwiftUI

struct WorkspaceContentView: View {
  @Environment(\.colorScheme) private var colorScheme
  let profile: WorkspaceLayoutProfile
  @Bindable var state: WorkspaceState

  private var destination: WorkspaceDestination { state.selectedDestination }

  var body: some View {
    VStack(alignment: .leading, spacing: profile.mainSectionSpacing) {
      utilityBar

      if !profile.usesSidebar {
        compactNavigation
      }

      heroSection
        .frame(maxWidth: .infinity)
        .padding(.top, profile.heroTopSpacing)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, profile.mainHorizontalPadding)
    .padding(.vertical, profile.mainVerticalPadding)
  }

  // MARK: - Subviews (extracted from platform-specific files)

  private var utilityBar: some View { ... }
  private var compactNavigation: some View { ... }
  private var heroSection: some View { ... }
  private var heroOrb: some View { ... }
  private var heroHeading: some View { ... }
  private var composerCard: some View { ... }
  private var quickPromptSection: some View { ... }
}
```

**Key insight:** The platform-specific differences were only:
- Layout constants (now in `WorkspaceLayoutProfile`)
- Presence of compact navigation (now `profile.usesSidebar`)
- iPad sidebar conditional

All visual components (orb, composer, chips, quick prompts) are pixel-identical across platforms.

---

## Phase 3: Extract Content Catalog (Week 1-2)

**Pattern:** Extract Class, Move Method

### Step 3.1: Create `WorkspaceContentCatalog`

**New file:** `OpenSpace/Features/Workspace/WorkspaceContentCatalog.swift`

```swift
struct WorkspaceContentCatalog {
  struct DestinationContent {
    let heroFirstLine: String
    let heroSecondLineLeading: String
    let heroAccentText: String
    let heroBody: String
    let composerPlaceholder: String
  }

  static func content(for destination: WorkspaceDestination) -> DestinationContent {
    switch destination {
    case .home:
      .init(
        heroFirstLine: "Good Afternoon, Bambang",
        heroSecondLineLeading: "What's on ",
        heroAccentText: "your mind?",
        heroBody: "A calmer desktop workspace for planning, asking, and moving between threads without visual noise.",
        composerPlaceholder: "Ask AI a question or make a request..."
      )
    // ... other cases
    }
  }
}
```

### Step 3.2: Slim down `WorkspaceDestination`

**File:** `OpenSpace/Features/Workspace/Models/WorkspaceDestination.swift`

```swift
enum WorkspaceDestination: String, CaseIterable, Hashable, Identifiable {
  case home, threads, recents, agents, files, share, data, help, settings

  var id: String { rawValue }

  var displayName: String {
    rawValue.capitalized
  }

  var systemImage: String {
    switch self {
    case .home:     "house"
    case .threads:  "bubble.left.and.bubble.right"
    case .recents:  "clock.arrow.circlepath"
    case .agents:   "sparkles.rectangle.stack"
    case .files:    "folder"
    case .share:    "point.3.connected.trianglepath"
    case .data:     "cylinder.split.1x2"
    case .help:     "headphones"
    case .settings: "gearshape"
    }
  }

  var navigationPlacement: WorkspaceNavigationPlacement {
    switch self {
    case .help, .settings: .utility
    default: .primary
    }
  }
}
```

---

## Phase 4: Collapse Platform Abstractions (Week 2)

**Pattern:** Collapse Hierarchy, Inline Class, Remove Middle Man

### Step 4.1: Delete abstract views and platform entry points

**Delete:**
- `OpenSpace/Features/Workspace/Views/WorkspaceAbstractView.swift`
- `OpenSpace/Features/Onboarding/Views/OnboardingAbstractView.swift`
- `OpenSpace/Features/Workspace/Views/iOS/WorkspaceIOSView.swift`
- `OpenSpace/Features/Workspace/Views/iPad/WorkspaceIPadView.swift`
- `OpenSpace/Features/Workspace/Views/Mac/WorkspaceMacView.swift`
- `OpenSpace/Features/Onboarding/Views/iOS/OnboardingIOSView.swift`
- `OpenSpace/Features/Onboarding/Views/iPad/OnboardingIPadView.swift`
- `OpenSpace/Features/Onboarding/Views/Mac/OnboardingMacView.swift`

### Step 4.2: Refactor `WorkspaceView` to use adaptive layout

**File:** `OpenSpace/Features/Workspace/WorkspaceView.swift`

```swift
import SwiftUI
#if os(macOS)
import AppKit
#endif

struct WorkspaceView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var state = WorkspaceState()
  @FocusState private var isPromptFocused: Bool

  let replayOnboarding: () -> Void

  var body: some View {
    GeometryReader { proxy in
      let profile = layoutProfile(for: proxy.size)

      ZStack {
        WorkspaceBackdrop(isAnimated: state.hasAppeared && !reduceMotion)

        contentSurface(profile: profile)
      }
      .task {
        guard !state.hasAppeared else { return }
        state.hasAppeared = true
        state.replayOnboarding = replayOnboarding
        #if os(macOS)
        configureMacWindow(profile: profile)
        #endif
      }
    }
  }

  @ViewBuilder
  private func contentSurface(profile: WorkspaceLayoutProfile) -> some View {
    let content = WorkspaceContentView(profile: profile, state: state)
      .frame(maxWidth: profile.shellMaxWidth)
      .padding(.horizontal, profile.shellHorizontalPadding)
      .padding(.vertical, profile.shellVerticalPadding)
      .opacity(state.hasAppeared ? 1 : 0)
      .offset(y: state.hasAppeared ? 0 : 24)
      .scaleEffect(reduceMotion ? 1 : (state.hasAppeared ? 1 : 0.985))
      .animation(.easeOut(duration: 0.85), value: state.hasAppeared)

    #if os(macOS)
      content
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    #else
      ScrollView(.vertical, showsIndicators: false) {
        content
      }
    #endif
  }

  private func layoutProfile(for size: CGSize) -> WorkspaceLayoutProfile {
    #if os(macOS)
      MacLayoutProfile(containerSize: size)
    #elseif os(iOS)
      if UIDevice.current.userInterfaceIdiom == .pad {
        IPadLayoutProfile(containerSize: size)
      } else {
        IOSLayoutProfile(containerSize: size)
      }
    #else
      IOSLayoutProfile(containerSize: size)
    #endif
  }

  #if os(macOS)
  private func configureMacWindow(profile: WorkspaceLayoutProfile) { ... }
  #endif
}
```

---

## Phase 5: Unified Onboarding (Week 2-3)

Apply the same collapse to Onboarding:

1. Create `OnboardingState` (@Observable)
2. Create `OnboardingContentView` (unified, adaptive)
3. Delete platform-specific onboarding trees
4. Keep only genuinely divergent components (e.g., macOS desktop canvas vs iPhone floating showcase)

**File:** `OpenSpace/Features/Onboarding/OnboardingContentView.swift`

```swift
struct OnboardingContentView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Bindable var state: OnboardingState

  var body: some View {
    ViewThatFits {
      // Wide layout (macOS, iPad landscape)
      OnboardingWideLayout(state: state)

      // Compact layout (iPhone, iPad portrait)
      OnboardingCompactLayout(state: state)
    }
  }
}
```

---

## Proposed Final Folder Structure

```
OpenSpace/
├── App/
│   ├── OpenSpaceApp.swift
│   └── AppRootView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift           # Entry point + state
│   │   ├── OnboardingContentView.swift    # Unified adaptive layout
│   │   ├── OnboardingState.swift          # @Observable state
│   │   ├── OnboardingVisuals.swift        # Backdrop, panels, effects
│   │   └── Views/
│   │       ├── OnboardingWideLayout.swift
│   │       ├── OnboardingCompactLayout.swift
│   │       ├── OnboardingHeader.swift
│   │       ├── OnboardingHero.swift
│   │       ├── OnboardingFooter.swift
│   │       └── OnboardingCapabilityStrip.swift
│   └── Workspace/
│       ├── WorkspaceView.swift            # Entry point + state
│       ├── WorkspaceContentView.swift     # Unified adaptive layout
│       ├── WorkspaceState.swift           # @Observable state
│       ├── WorkspaceContentCatalog.swift  # Text content
│       ├── WorkspaceBackdropView.swift
│       └── Views/
│           ├── WorkspaceNavigation.swift
│           ├── WorkspaceUtilityBar.swift
│           ├── WorkspaceHeroSection.swift
│           ├── WorkspaceComposerCard.swift
│           └── WorkspaceQuickPrompts.swift
├── Shared/
│   ├── Theme/
│   │   ├── ThemeColors.swift
│   │   └── ThemeExtensions.swift
│   ├── Layout/
│   │   ├── WorkspaceLayoutProfile.swift
│   │   └── PlatformProfiles.swift
│   └── Models/
│       ├── WorkspaceDestination.swift     # Slim navigation enum
│       ├── WorkspaceModel.swift           # AI model config
│       ├── WorkspaceWritingStyle.swift
│       └── QuickPrompt.swift              # Struct, not enum
├── OpenSpaceTests/
└── OpenSpaceUITests/
```

**Line count reduction estimate:**

| Category | Before | After | Reduction |
|----------|--------|-------|-----------|
| Workspace platform views | 1,848 | 350 | 81% |
| Onboarding platform views | 1,000 | 250 | 75% |
| Models / Context / Bindings | 550 | 180 | 67% |
| Preview Support | 175 | 60 | 66% |
| **Total** | **~3,573** | **~840** | **76%** |

---

## Migration Order (Safe, Incremental)

1. **Day 1**: Remove TCA dependency (safe, no code uses it)
2. **Day 2-3**: Extract `WorkspaceLayoutProfile` + platform profiles
3. **Day 4-5**: Create `WorkspaceState`, migrate one platform view at a time
4. **Day 6-7**: Delete old platform views once unified view is verified
5. **Week 2**: Repeat for Onboarding
6. **Week 3**: Extract content catalog, add tests

---

## Verification Checklist

- [ ] Build succeeds on iOS Simulator
- [ ] Build succeeds on macOS
- [ ] All previews render correctly
- [ ] Accessibility identifiers preserved
- [ ] Animations behave identically
- [ ] macOS window sizing preserved
- [ ] iPad sidebar logic preserved
- [ ] Build time benchmarked before/after
