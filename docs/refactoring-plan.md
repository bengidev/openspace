# OpenSpace Refactoring Plan

**Project:** OpenSpace  
**Based on:** `docs/code-smell-analysis.md`  
**Strategy:** Incremental, safe, one phase per commit

---

## Philosophy

> Do NOT rewrite everything at once. Each phase must leave the project buildable and behaviorally identical.

Per the architecture-smell-audit skill:
- Do NOT recommend heavy architectures for prototypes
- Do NOT create abstractions before they are needed (YAGNI)
- Do NOT split into SPM modules for small codebases
- Each phase should be a single logical commit

---

## Phase 1: Consolidate Workspace ContentViews (P0)

**Goal:** Merge iOS/iPad/Mac ContentViews into shared views + RenderContext metrics
**Est. Impact:** −~840 lines
**Risk:** Medium (touches core workspace UI)
**Verification:** Build for iOS, iPad, macOS; verify visual parity via previews

### Step 1.1 — Extend WorkspaceRenderContext
File: `Features/Workspace/Views/Shared/WorkspaceRenderContext.swift`

Add the remaining 17 per-view computed properties so no view ever needs to switch on `variant` directly:

```swift
var heroOrbSize: CGFloat { ... }
var heroHeadingSpacing: CGFloat { ... }
var heroHeadingMaxWidth: CGFloat? { ... }
var composerVStackSpacing: CGFloat { ... }
var composerTextFont: Font { ... }
var composerMinHeight: CGFloat { ... }
var composerLineLimit: ClosedRange<Int> { ... }
var composerPadding: CGFloat { ... }
var composerCornerRadius: CGFloat { ... }
var composerUsesCompactFallback: Bool { ... }
var toggleScale: CGFloat { ... }
var quickPromptMinHeight: CGFloat { ... }
var quickPromptPadding: CGFloat { ... }
var utilityBarShowsInvite: Bool { ... }
var utilityBarSearchIsTextButton: Bool { ... }
```

### Step 1.2 — Create Shared Content Views
New file: `Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift`

Extract generic, prefix-free versions of:
- `WorkspaceMainContent`
- `WorkspaceUtilityBar`
- `WorkspaceBarIconButton`
- `WorkspaceBarButton`
- `WorkspaceHeroOrb`
- `WorkspaceHeroHeading`
- `WorkspaceComposerCard`
- `WorkspaceSurfaceChip`
- `WorkspaceQuickPromptSection`

All take `context: WorkspaceRenderContext` and `bindings: WorkspaceViewBindings` only.

### Step 1.3 — Thin the Platform Files
Reduce these files to 5-line wrappers:
- `WorkspaceIOSContentViews.swift`
- `WorkspaceIPadContentViews.swift`
- `WorkspaceMacContentViews.swift`

```swift
struct WorkspaceIOSMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings
  var body: some View {
    WorkspaceMainContent(context: context, bindings: bindings)
  }
}
```

### Step 1.4 — Update Call Sites
Update `WorkspaceAbstractView` (or its callers) to use the shared views.

---

## Phase 2: Merge Onboarding Mobile Views (P0)

**Goal:** Unify iOS + iPad onboarding into parameterized mobile views
**Est. Impact:** −~400 lines
**Risk:** Low (onboarding is less stateful than workspace)
**Verification:** Build + preview for iPhone and iPad

### Step 2.1 — Extract Shared Subviews
New file: `Features/Onboarding/Views/Shared/OnboardingSharedViews.swift`

Create parameterized versions of:
- `OnboardingAnimatedPanel`
- `OnboardingCapabilityStrip`
- `OnboardingSupportingNote`
- `OnboardingFooterView` (replaces 3 proxy files)

### Step 2.2 — Merge iOS + iPad Views
New file: `Features/Onboarding/Views/OnboardingMobileView.swift`

Replace `OnboardingIOSView` and `OnboardingIPadView` with a single view taking:
- `variant: OnboardingPlatformVariant`
- `context: OnboardingRenderContext`
- `onContinue: () -> Void`

Drive text strings, chip arrays, and layout values from the variant.

### Step 2.3 — Merge Mobile Header
New file: `Features/Onboarding/Views/OnboardingMobileHeaderView.swift`

Replace `OnboardingIOSHeaderView` + `OnboardingIPadHeaderView` with one parameterized view.

### Step 2.4 — Clean Up
Delete:
- `OnboardingIOSView.swift` (if fully merged)
- `OnboardingIPadView.swift` (if fully merged)
- `OnboardingIOSHeaderView.swift`
- `OnboardingIPadHeaderView.swift`
- `Onboarding{IOS|IPad|Mac}FooterView.swift`
- `OnboardingIOSPanel` / `OnboardingIPadPanel` private structs
- `OnboardingIOSCapabilityStrip` / `OnboardingIPadCapabilityStrip`
- `OnboardingIOSSupportingNote` / `OnboardingIPadSupportingNote`

---

## Phase 3: Remove Middle Man Abstractions (P1)

**Goal:** Delete empty AbstractView wrappers
**Est. Impact:** −~50 lines, −1 abstraction layer
**Risk:** Low
**Verification:** Build all platforms

### Step 3.1 — Delete OnboardingAbstractView
- Move the `switch variant` dispatch into the call site (`OnboardingView.swift` or `AppRootView.swift`)
- Delete `OnboardingAbstractView.swift`

### Step 3.2 — Delete WorkspaceAbstractView
- Same pattern: inline the switch at the call site
- Delete `WorkspaceAbstractView.swift`

### Step 3.3 — Inline Footer Proxies
- Replace `OnboardingMetadataBar` wrappers with direct usage + parameters

---

## Phase 4: Split Large Classes (P1)

**Goal:** Reduce God Object surface
**Est. Impact:** −~80 lines of confusion, +4 focused files
**Risk:** Low (no behavior changes, only file moves)
**Verification:** Build all platforms

### Step 4.1 — Split ThemeColors.swift
- `Shared/Theme/DesignTokens.swift` — `AppTheme`, gradients
- `Shared/Theme/Color+Hex.swift` — `Color.init(hex:)` extension
- `Shared/Theme/ThemeColor.swift` — semantic color namespace

### Step 4.2 — Split WorkspaceModels.swift
- `Features/Workspace/Views/Shared/WorkspaceViewBindings.swift`
- `Features/Workspace/Views/Shared/WorkspacePalette.swift` (merge with existing)
- `Shared/Models/WorkspaceDestination+UI.swift` — hero bodies, placeholders, strings

---

## Phase 5: Fix Documentation & Orphans (P2)

**Goal:** Align docs with code; remove dead code
**Risk:** None

### Step 5.1 — Update architecture-review.md
Rewrite `docs/architecture-review.md` to reflect:
- TCA is actively used (AppFeature, WorkspaceFeature, OnboardingFeature)
- `@Dependency(\.apiClient)` pattern
- TCA-managed state for onboarding flow

### Step 5.2 — Decide WorkspaceContentView.swift Fate
- **Option A:** Delete `WorkspaceContentView.swift` (orphaned, references non-existent types)
- **Option B:** Finish TCA migration to replace platform variants (requires significant work)

**Recommendation:** Option A. The file has been abandoned and the platform variants are the source of truth.

---

## Proposed Final Folder Structure

```text
OpenSpace/
├── App/
│   ├── OpenSpaceApp.swift
│   └── AppRootView.swift
├── Features/
│   ├── App/
│   │   └── AppFeature.swift
│   ├── Onboarding/
│   │   ├── OnboardingFeature.swift
│   │   ├── OnboardingView.swift
│   │   ├── OnboardingVisuals.swift
│   │   ├── OnboardingButtonAndMetadataViews.swift
│   │   ├── OnboardingSignalAndEffectViews.swift
│   │   └── Views/
│   │       ├── OnboardingMobileView.swift      # iOS + iPad unified
│   │       ├── OnboardingMacView.swift
│   │       ├── OnboardingMobileHeaderView.swift
│   │       ├── OnboardingMacHeaderView.swift
│   │       ├── OnboardingMobileHeroView.swift
│   │       ├── OnboardingMacHeroView.swift
│   │       ├── Shared/
│   │       │   ├── OnboardingPlatformVariant.swift
│   │       │   ├── OnboardingRenderContext.swift
│   │       │   ├── OnboardingSharedViews.swift
│   │       │   └── OnboardingIdentifierSupport.swift
│   │       ├── iOS/                         # only truly iOS-specific views
│   │       ├── iPad/                        # only truly iPad-specific views
│   │       └── Mac/
│   │           ├── OnboardingMacLayout.swift
│   │           ├── OnboardingMacHeroSupportViews.swift
│   │           └── ...
│   └── Workspace/
│       ├── WorkspaceFeature.swift
│       ├── WorkspaceView.swift
│       ├── WorkspaceContentCatalog.swift
│       ├── WorkspaceBackdropView.swift
│       ├── WorkspacePreviewSupport.swift
│       └── Views/
│           ├── WorkspaceMainView.swift         # thin platform wrappers
│           ├── WorkspaceIOSView.swift          # ~20 lines
│           ├── WorkspaceIPadView.swift         # ~20 lines
│           ├── WorkspaceMacView.swift          # ~20 lines
│           ├── Shared/
│           │   ├── WorkspaceSharedContentViews.swift
│           │   ├── WorkspaceRenderContext.swift
│           │   ├── WorkspacePlatformVariant.swift
│           │   ├── WorkspaceViewBindings.swift
│           │   ├── WorkspacePalette.swift
│           │   └── WorkspaceModels.swift       # reduced
│           ├── iOS/                          # thin shells only
│           │   └── WorkspaceIOSContentViews.swift
│           ├── iPad/
│           │   └── WorkspaceIPadContentViews.swift
│           └── Mac/
│               └── WorkspaceMacContentViews.swift
├── Shared/
│   ├── API/
│   │   └── APIClient.swift
│   ├── Models/
│   │   ├── Thread.swift
│   │   ├── QuickPrompt.swift
│   │   ├── WorkspaceModel.swift
│   │   ├── WorkspaceDestination.swift
│   │   ├── WorkspaceWritingStyle.swift
│   │   └── WorkspaceDestination+UI.swift
│   ├── Theme/
│   │   ├── DesignTokens.swift
│   │   ├── Color+Hex.swift
│   │   └── ThemeColor.swift
│   └── Layout/
│       └── WorkspaceLayoutProfile.swift
└── docs/
    ├── code-smell-analysis.md
    ├── refactoring-plan.md
    └── refactoring-examples.md
```

---

## Line Count Reduction Estimate

| Phase | Before | After | Saved |
|---|---|---|---|
| Phase 1: Workspace ContentViews | ~1,573 | ~730 | ~843 |
| Phase 2: Onboarding mobile merge | ~833 | ~398 | ~435 |
| Phase 3: Remove Middle Man | ~75 | 0 | ~75 |
| Phase 4: Split Large Classes | ~567 | ~567 | 0 (same code, more files) |
| Phase 5: Delete orphan | ~448 | 0 | ~448 |
| **Total** | **~3,496** | **~1,695** | **~1,801** |

*Note: The total project is ~7,400 lines, so this represents a **~24% reduction** in the feature-layer surface.*

---

## Verification Checklist (per phase)

- [ ] Build succeeds for iOS target
- [ ] Build succeeds for iPad target
- [ ] Build succeeds for macOS target
- [ ] SwiftUI Previews render without errors
- [ ] No regression in accessibility identifiers
- [ ] No regression in color scheme handling
- [ ] Unit tests pass (if any exist beyond template)

---

## Next Steps

1. **Confirm** which Phase to begin (recommended: Phase 2 first because onboarding is lower risk)
2. **Execute** one phase at a time with review between each
3. **Update** this plan if new smells emerge during execution
