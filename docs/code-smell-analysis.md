# OpenSpace Code Smell Analysis

**Project:** OpenSpace  
**Date:** 23 April 2026  
**Analyzer:** Hermes Agent (architecture-smell-audit + swiftui-expert-skill)  
**Lines of Swift:** ~7,400 (59 files)  
**Reference:** [Refactoring.Guru](https://refactoring.guru/refactoring/smells)

---

## Executive Summary

| Smell | Severity | Files Affected | Est. Lines Saved |
|---|---|---|---|
| Duplicate Code (Platform Duplication) | **Critical** | 15+ view files | ~1,200 |
| Middle Man | **High** | AbstractView wrappers, Footer proxies | ~50 |
| Large Class / God Object | **Medium** | ThemeColors.swift, WorkspaceModels.swift | ~80 |
| Shotgun Surgery | **Medium** | Platform variant additions | N/A (design fix) |
| Documentation Drift | **Medium** | docs/architecture-review.md | — |
| Orphaned Code | **Low** | WorkspaceContentView.swift | ~448 |

**Total potential reduction: ~1,300–1,500 lines (~18–20% of codebase)**

---

## 1. Duplicate Code

**Refactoring.Guru Reference:** [Duplicate Code](https://refactoring.guru/smells/duplicate-code)  
**Category:** Dispensables  
**Definition:** *"Two code fragments look almost identical."*  
**Treatment:** Extract Method, Form Template Method, Extract Class

### Evidence

#### Workspace ContentViews (~85% identical across platforms)
- `Features/Workspace/Views/iOS/WorkspaceIOSContentViews.swift` (451 lines)
- `Features/Workspace/Views/iPad/WorkspaceIPadContentViews.swift` (454 lines)
- `Features/Workspace/Views/Mac/WorkspaceMacContentViews.swift` (421 lines)

The following private structs are copy-pasted with only a platform prefix changed:

| Struct | iOS | iPad | Mac | Duplication |
|---|---|---|---|---|
| SurfaceChip | X | X | X | 100% |
| HeroOrb | X | X | X | ~90% (only frame size varies) |
| HeroHeading | X | X | X | ~90% (VStack spacing & maxWidth) |
| QuickPromptSection | X | X | X | ~95% (minHeight & padding vary) |
| UtilityBar | X | X | X | ~80% (search button style varies) |
| ComposerCard | X | X | X | ~70% (fonts, metrics vary) |
| MainContent | X | X | X | ~85% (compact nav condition varies) |

**What actually varies:** Only 12 scalar values and 3 structural booleans differ. All visual primitives (Capsule stroke overlays, Circle fills, RoundedRectangle backgrounds, palette lookups) are repeated verbatim.

#### Onboarding Mobile Views (~85–100% identical iOS/iPad)
- `Features/Onboarding/Views/iOS/OnboardingIOSView.swift` (174 lines)
- `Features/Onboarding/Views/iPad/OnboardingIPadView.swift` (180 lines)
- `Features/Onboarding/Views/iOS/OnboardingIOSHeaderView.swift` (~87 lines)
- `Features/Onboarding/Views/iPad/OnboardingIPadHeaderView.swift` (~88 lines)

Near-identical wrappers:
- `OnboardingIOSPanel` / `OnboardingIPadPanel` → 100% identical
- `OnboardingIOSCapabilityStrip` / `OnboardingIPadCapabilityStrip` → 100% identical
- `OnboardingIOSSupportingNote` / `OnboardingIPadSupportingNote` → 100% identical
- `Onboarding{IOS|IPad|Mac}FooterView` → ~90% identical (thin proxies around `OnboardingMetadataBar`)

### Why It Hurts
> *"Duplication usually occurs when multiple programmers are working on different parts of the same program at the same time... novice programmers may not be able to resist the temptation of copying and pasting the relevant code."* — Refactoring.Guru

Every bug fix, color tweak, or accessibility improvement must be applied 3 times. The probability of inconsistency approaches 1 as the codebase grows.

### Recommended Fix
1. **Extract shared subviews** into `Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift`
2. **Move per-view metrics** into `WorkspaceRenderContext` (only 12 values differ)
3. **Merge iOS + iPad onboarding** into a single `OnboardingMobileView` parameterized by variant
4. **Form Template Method** for footers/panels/capability strips

---

## 2. Middle Man

**Refactoring.Guru Reference:** [Middle Man](https://refactoring.guru/smells/middle-man)  
**Category:** Couplers  
**Definition:** *"If a class performs only one action, delegating work to another class, why does it exist at all?"*  
**Treatment:** Remove Middle Man

### Evidence

#### OnboardingAbstractView
`Features/Onboarding/Views/OnboardingAbstractView.swift` (25 lines)

```swift
struct OnboardingAbstractView: View {
  let variant: OnboardingPlatformVariant
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    switch variant {
    case .ios: OnboardingIOSView(context: context, onContinue: onContinue)
    case .ipad: OnboardingIPadView(context: context, onContinue: onContinue)
    case .mac: OnboardingMacView(context: context, onContinue: onContinue)
    }
  }
}
```

This is a pure switch/router. It adds indirection without behavior. Callers could dispatch directly; deleting it loses nothing.

#### WorkspaceAbstractView
`Features/Workspace/Views/WorkspaceAbstractView.swift` (25 lines)

Identical pattern: resolves platform variant and forwards to concrete view. No transformation, no shared logic.

#### Platform Footer Proxies
- `OnboardingIOSFooterView` → wraps `OnboardingMetadataBar` with 3 parameters
- `OnboardingIPadFooterView` → same wrapper, different parameter values
- `OnboardingMacFooterView` → same wrapper, different parameter values

These are proxy views that add no behavior; the parameters could be passed directly.

### Why It Hurts
> *"This smell can be the result of overzealous elimination of Message Chains... The class remains as an empty shell that doesn't do anything other than delegate."* — Refactoring.Guru

Every navigation to a concrete view requires mentally unpacking one layer of abstraction that provides zero insulation.

### Recommended Fix
- **Delete** `OnboardingAbstractView.swift` and `WorkspaceAbstractView.swift`
- Replace with a factory function at the single call site:
  ```swift
  @ViewBuilder
  func makeOnboardingView(variant: OnboardingPlatformVariant, ...) -> some View { ... }
  ```
- **Inline** the three FooterViews into a single parameterized view

---

## 3. Large Class / God Object

**Refactoring.Guru Reference:** [Large Class](https://refactoring.guru/smells/large-class)  
**Category:** Bloaters  
**Definition:** *"A class contains many fields/methods/lines of code."*  
**Treatment:** Extract Class, Extract Subclass, Extract Interface

### Evidence

#### ThemeColors.swift
`Shared/Theme/ThemeColors.swift` — **264 lines**

Mixes:
- `AppTheme` struct (color constants)
- `Color` hex helper extensions
- `ThemeColor` namespace (40+ static color functions)
- `Gradient` builders
- Platform-specific `#if canImport(UIKit)` branches

This file wears too many hats. It is both a design token registry and a color utility library.

#### WorkspaceModels.swift
`Features/Workspace/Views/Shared/WorkspaceModels.swift` — **303 lines**

Mixes:
- `WorkspacePalette` enum (20+ static color functions)
- `WorkspaceViewBindings` struct
- `WorkspaceDestination` extensions (UI strings, hero bodies, composer placeholders)
- `QuickPrompt` extensions
- `WorkspaceWritingStyle` extensions

Palette logic and domain model UI strings are coupled in one file.

### Recommended Fix
1. **Extract Class:** Split `ThemeColors.swift` into:
   - `Theme/DesignTokens.swift` — raw colors, gradients
   - `Theme/Color+Hex.swift` — hex initializer extension
   - `Theme/ThemeColor.swift` — semantic color namespace
2. **Extract Class:** Split `WorkspaceModels.swift` into:
   - `Workspace/WorkspacePalette.swift` — already exists, consolidate
   - `Workspace/WorkspaceViewBindings.swift`
   - `Models/WorkspaceDestination+UI.swift`

---

## 4. Shotgun Surgery

**Refactoring.Guru Reference:** [Shotgun Surgery](https://refactoring.guru/smells/shotgun-surgery)  
**Category:** Change Preventers  
**Definition:** *"Making any modifications requires that you make many small changes to many different classes."*  
**Treatment:** Move Method, Move Field, Inline Class

### Evidence

Adding a new platform (e.g. visionOS) or changing a shared view requires edits to:

1. `WorkspacePlatformVariant.swift` — add enum case
2. `WorkspaceAbstractView.swift` — add switch branch
3. `WorkspaceRenderContext.swift` — add platform metrics
4. `WorkspaceIOSContentViews.swift` / `iPad` / `Mac` — create new file
5. `Workspace{Platform}View.swift` — create new file
6. `Workspace{Platform}ShellView.swift` — create new file
7. `OnboardingAbstractView.swift` — add switch branch
8. Repeat for onboarding headers, footers, heroes

> *"A single responsibility has been split up among a large number of classes."* — Refactoring.Guru

### Recommended Fix
- **Consolidate** platform-specific ContentViews into one shared file driven by `RenderContext`
- **Remove** AbstractView layer so new platforms only need: variant enum + render context metrics + one thin view wrapper

---

## 5. Documentation Drift

**Severity:** Medium  
**File:** `docs/architecture-review.md`

This document explicitly states:

> *"There is no current need for: TCA reducers, repository abstractions, SwiftData DTO mapping, dependency injection frameworks, navigation coordinators... Do not introduce TCA unless multiple interacting features and async effects make state coordination hard to reason about."*

**Reality:** The codebase now fully integrates The Composable Architecture (TCA):
- `AppFeature.swift` — TCA reducer with `@Reducer`, `@ObservableState`
- `WorkspaceFeature.swift` — TCA reducer with `BindingReducer`, `@Dependency(\.apiClient)`
- `OnboardingFeature.swift` — TCA reducer with async effects
- `ComposableArchitecture` imported in **9 files**

The documentation contradicts the code, making it untrustworthy for new team members.

### Recommended Fix
- Rewrite `docs/architecture-review.md` to reflect the actual TCA-based architecture
- Or delete it and replace with auto-generated architecture diagrams from the source

---

## 6. Orphaned Code

**Severity:** Low  
**File:** `Features/Workspace/Views/WorkspaceContentView.swift` — **448 lines**

This file references types that do not exist in the current workspace:
- `WorkspaceLayoutProfile`
- `WorkspaceFeature` (in a different shape than the current TCA implementation)

It hard-codes iOS metrics and drops iPad/Mac layout differences. It appears to be an abandoned consolidation attempt from a parallel branch.

### Recommended Fix
- **Delete** `WorkspaceContentView.swift` entirely, or
- **Finish** the TCA migration so it respects the same metric matrix as the platform variants

---

## Severity Matrix

| Smell | Frequency | Impact | Effort to Fix | Priority |
|---|---|---|---|---|
| Duplicate Code (Workspace) | High | Very High | Medium | **P0 — Do first** |
| Duplicate Code (Onboarding) | High | High | Low | **P0** |
| Middle Man | Medium | Medium | Low | **P1** |
| Large Class | Medium | Medium | Low | **P1** |
| Shotgun Surgery | High | Medium | Medium | **P1** |
| Documentation Drift | Low | Medium | Low | **P2** |
| Orphaned Code | Low | Low | Low | **P2** |
