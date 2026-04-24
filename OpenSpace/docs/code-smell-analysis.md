# OpenSpace Code Smell Analysis

> Analysis date: 2026-04-23
> Based on: Refactoring.Guru code smell catalog (https://refactoring.guru/refactoring/smells)
> Scope: Full SwiftUI project audit for monolith patterns, coupling, and bloaters

---

## Executive Summary

The OpenSpace project exhibits **10+ distinct code smells** across all categories in the Refactoring.Guru catalog: Bloaters, Object-Orientation Abusers, Change Preventers, Dispensables, and Couplers. The most critical issue is **massive cross-platform duplication** (~2,800 lines of nearly identical UI code across iOS/iPad/Mac variants) combined with a **God Object** data model and an **unused TCA dependency** that inflates build times.

Severity matrix:

| Smell | Severity | Files Affected | Ref.Guru Category |
|-------|----------|----------------|-------------------|
| Duplicate Code | Critical | 15+ files | Dispensables |
| Large Class / God Object | High | WorkspaceModels.swift | Bloaters |
| Speculative Generality | High | AbstractView pattern | Dispensables |
| Dead Code (unused TCA) | High | OpenSpaceApp.swift | Dispensables |
| Switch Statements | Medium | WorkspaceRenderContext.swift | OO Abusers |
| Data Clumps | Medium | WorkspaceViewBindings | Bloaters |
| Feature Envy | Medium | WorkspaceDestination | Couplers |
| Middle Man | Medium | AbstractViews | Couplers |
| Shotgun Surgery | Medium | Platform additions | Change Preventers |
| Primitive Obsession | Low | WorkspaceQuickPrompt | Bloaters |

---

## 1. Duplicate Code (Critical)

**Ref.Guru:** https://refactoring.guru/smells/duplicate-code

### Evidence

Three platform content views share 90%+ identical structure:

```
WorkspaceIOSContentViews.swift    (451 lines)
WorkspaceMacContentViews.swift    (421 lines)
WorkspaceIPadContentViews.swift   (454 lines)
```

Each contains near-identical private structs:
- `WorkspaceIOSUtilityBar` / `WorkspaceMacUtilityBar` / `WorkspaceIPadUtilityBar`
- `WorkspaceIOSHeroOrb` / `WorkspaceMacHeroOrb` / `WorkspaceIPadHeroOrb`
- `WorkspaceIOSComposerCard` / `WorkspaceMacComposerCard` / `WorkspaceIPadComposerCard`
- `WorkspaceIOSQuickPromptSection` / `WorkspaceMacQuickPromptSection` / `WorkspaceIPadQuickPromptSection`

The only differences are:
1. Struct name prefixes (IOS/Mac/IPad)
2. Minor layout constants (padding, font sizes) already parameterized in `WorkspaceRenderContext`
3. iPad has a conditional `usesSidebar` branch; iOS has compact navigation

### Why This Is a Problem

Per Refactoring.Guru: *"If you see the same code structure in more than one place, you can be sure that your program will be better if you find a way to unify them."*

- **Maintenance burden**: Bug fixes must be applied 3x
- **Inconsistency risk**: Visual drift between platforms over time
- **Compilation bloat**: 1,326 lines of duplicated SwiftUI view code

### Recommended Fix

**Extract Unified Components** + **Extract Method** patterns.

Create a single `WorkspaceContentView.swift` that accepts a `WorkspaceLayoutProfile` (replacing the enum-based `WorkspaceRenderContext`). Platform-specific layout values become injected configuration, not branching logic.

See `/docs/refactoring-plan.md` for the unified structure.

---

## 2. Large Class / God Object (High)

**Ref.Guru:** https://refactoring.guru/smells/large-class

### Evidence

`WorkspaceModels.swift` (303 lines) contains 7 unrelated concepts:

```swift
enum WorkspacePalette          // Theme color mapping (~89 lines)
enum WorkspaceNavigationPlacement
enum WorkspaceDestination      // Navigation + hero text + composer placeholder (~157 lines)
enum WorkspaceModel            // AI model selection
enum WorkspaceWritingStyle     // Writing style selection
enum WorkspaceQuickPrompt      // Quick prompt data
struct WorkspaceViewBindings   // Binding aggregation (~8 lines)
```

`WorkspaceDestination` alone mixes:
- Navigation metadata (`systemImage`, `navigationPlacement`)
- Marketing copy (`heroFirstLine`, `heroSecondLineLeading`, `heroAccentText`, `heroBody`)
- UI state (`composerPlaceholder`)

### Why This Is a Problem

Refactoring.Guru: *"A class that knows too much or does too much... splitting it up makes the parts easier to understand and maintain."*

- **Single Responsibility Violation**: Changing marketing copy requires modifying a navigation enum
- **Cognitive load**: Developers must load 300 lines to understand any one concept
- **Merge conflicts**: Multiple developers editing the same file for different reasons

### Recommended Fix

**Extract Class** pattern:

```
WorkspaceDestination.swift     // Navigation identity only
WorkspaceContentCatalog.swift  // Hero text, body copy, placeholders
WorkspacePalette.swift         // Colors (or merge into ThemeColors)
WorkspaceConfig.swift          // Model, WritingStyle, QuickPrompt
```

---

## 3. Speculative Generality (High)

**Ref.Guru:** https://refactoring.guru/smells/speculative-generality

### Evidence

The entire platform abstraction tree (`AbstractView` -> iOS/iPad/Mac branches) exists for a **prototype-stage project** with 2 screens (onboarding + workspace shell).

```
OnboardingAbstractView.swift     // 25 lines, only switches
WorkspaceAbstractView.swift      // 25 lines, only switches
OnboardingRenderContext.swift    // 19 lines
WorkspaceRenderContext.swift     // 247 lines of switch-on-variant
PlatformVariant enums
PreviewSupport enums per feature
```

The project's own `architecture-review.md` states:
> "The repository is currently about refining onboarding direction, not about delivering a full AI workspace."

Yet the codebase carries 3 full platform render trees (2,848 lines total for platform-specific views).

### Why This Is a Problem

Refactoring.Guru: *"There's an unused class, method, field or parameter... originally created for something but was never supported."*

- **Premature abstraction**: macOS and iPad layouts are not meaningfully different from iOS at this stage
- **Cognitive overhead**: Developers must understand 4 layers (View -> AbstractView -> PlatformView -> Subviews) to make a change
- **Build time**: More files = more Swift module compilation

### Recommended Fix

**Collapse Hierarchy** + **Inline Class** patterns.

For the current prototype stage, use **adaptive layout** with `ViewThatFits`, `horizontalSizeClass`, and `GeometryReader` instead of compile-time platform branching. Extract platform-specific code only when a platform genuinely diverges (e.g., macOS menu bars, iPad multi-window).

See Section 6 in `/docs/refactoring-plan.md` for the adaptive approach.

---

## 4. Dead Code (High)

**Ref.Guru:** https://refactoring.guru/smells/dead-code

### Evidence

The project links `ComposableArchitecture` (TCA) SPM package but uses it **nowhere**:

```swift
// OpenSpaceApp.swift
import ComposableArchitecture   // <-- Only import site in entire project

// WorkspaceView.swift, OnboardingView.swift
@State private var ...          // <-- Plain SwiftUI state, no Store, no Reducer
```

`project.pbxproj` confirms the dependency is linked to all targets (main, tests, UITests), adding:
- `swift-syntax` compilation cascade
- `CasePaths`, `Dependencies`, `Perception`, `Sharing`, `Clocks`, `CombineSchedulers` transitive deps
- ~20 additional Swift modules per build

### Why This Is a Problem

Refactoring.Guru: *"A variable, parameter, field, method or class is no longer used... it complicates the code and creates dependencies."*

Per the `spm-build-analysis` skill: Swift macro rebuild cascading from TCA can turn trivial source changes into near-full rebuilds.

### Recommended Fix

**Remove Unused Dependency** immediately:

1. Remove `ComposableArchitecture` from Xcode project SPM dependencies
2. Delete `import ComposableArchitecture` from `OpenSpaceApp.swift`
3. Clean build folder and verify compilation

Re-introduce TCA **only** when the app has:
- 3+ interacting features
- Complex async effects
- Real need for time-travel debugging or testable state machines

---

## 5. Switch Statements (Medium)

**Ref.Guru:** https://refactoring.guru/smells/switch-statements

### Evidence

`WorkspaceRenderContext` contains **~20 computed properties**, each switching on `variant`:

```swift
var shellMaxWidth: CGFloat {
  switch variant {
  case .ios:   760
  case .ipad:  1380
  case .mac:   1440
  }
}

var shellHorizontalPadding: CGFloat {
  switch variant {
  case .ios:   min(max(containerSize.width * 0.038, 16), 22)
  case .ipad:  min(max(containerSize.width * 0.03, 18), 32)
  case .mac:   0
  }
}
// ... repeated 20 more times
```

### Why This Is a Problem

Refactoring.Guru: *"A complex switch operator or sequence of if statements... suggests polymorphism should be used instead."*

- Adding a new platform (e.g., visionOS) requires editing 20+ locations
- The context object is doing the job that should belong to platform-specific configuration objects

### Recommended Fix

**Replace Conditional with Polymorphism** pattern.

Create a `WorkspaceLayoutProfile` protocol with implementations `IOSLayoutProfile`, `IPadLayoutProfile`, `MacLayoutProfile`. The context receives a `profile: WorkspaceLayoutProfile` and delegates all layout queries to it.

```swift
protocol WorkspaceLayoutProfile {
  var shellMaxWidth: CGFloat { get }
  var shellHorizontalPadding: CGFloat { get }
  // ...
}

struct IOSLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize
  var shellMaxWidth: CGFloat { 760 }
  var shellHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.038, 16), 22)
  }
}
```

---

## 6. Data Clumps (Medium)

**Ref.Guru:** https://refactoring.guru/smells/data-clumps

### Evidence

`WorkspaceViewBindings` aggregates 8 related values:

```swift
struct WorkspaceViewBindings {
  let selectedDestination: Binding<WorkspaceDestination>
  let selectedModel: Binding<WorkspaceModel>
  let selectedPrompt: Binding<String>
  let selectedWritingStyle: Binding<WorkspaceWritingStyle>
  let citationEnabled: Binding<Bool>
  let highlightedQuickPrompt: Binding<WorkspaceQuickPrompt?>
  let isPromptFocused: FocusState<Bool>.Binding
  let replayOnboarding: () -> Void
}
```

Similarly, `WorkspacePreviewSupport.preview(...)` takes 8 parameters to initialize these states.

### Why This Is a Problem

Refactoring.Guru: *"Sometimes different parts of the code contain identical groups of variables... these clumps should be turned into their own classes."*

- Passing the clump through 4+ view layers (View -> AbstractView -> PlatformView -> ContentView)
- Adding a new state property requires updating `WorkspaceViewBindings`, `WorkspacePreviewSupport`, `WorkspacePreviewHarness`, and all platform views

### Recommended Fix

**Introduce Parameter Object** + **Extract Class** patterns.

Create a single `@Observable` class (or `@StateObject` for iOS 16) that owns all workspace state:

```swift
@Observable
final class WorkspaceState {
  var selectedDestination: WorkspaceDestination = .home
  var selectedModel: WorkspaceModel = .chatGPT4o
  var selectedPrompt: String = ""
  var selectedWritingStyle: WorkspaceWritingStyle = .balanced
  var citationEnabled: Bool = true
  var highlightedQuickPrompt: WorkspaceQuickPrompt?
  var isPromptFocused: Bool = false
  var replayOnboarding: () -> Void = {}
}
```

Inject `WorkspaceState` via environment or init, eliminating the `WorkspaceViewBindings` clump entirely.

---

## 7. Feature Envy (Medium)

**Ref.Guru:** https://refactoring.guru/smells/feature-envy

### Evidence

`WorkspaceDestination` (a navigation enum) contains extensive marketing copy and UI strings:

```swift
enum WorkspaceDestination {
  var heroFirstLine: String { ... }        // 9 cases
  var heroSecondLineLeading: String { ... } // 9 cases
  var heroAccentText: String { ... }        // 9 cases
  var heroBody: String { ... }              // 9 cases (very long)
  var composerPlaceholder: String { ... }   // 9 cases
}
```

This is 150+ lines of content copy inside a navigation data type.

### Why This Is a Problem

Refactoring.Guru: *"A method that seems more interested in a class other than the one it actually is in... move the method to the class it is envious of."*

- Navigation logic and content copy are unrelated concerns
- Localization would be difficult (strings embedded in enum computed properties)
- Content writers cannot edit copy without touching Swift code

### Recommended Fix

**Move Method** + **Extract Class** patterns.

Move all string content to a dedicated content catalog:

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
    case .home:    .init(heroFirstLine: "Good Afternoon, Bambang", ...)
    case .threads: .init(heroFirstLine: "Pick up an", ...)
    // ...
    }
  }
}
```

Or better, use `LocalizedStringKey` / `.strings` files for true localization support.

---

## 8. Middle Man (Medium)

**Ref.Guru:** https://refactoring.guru/smells/middle-man

### Evidence

```swift
// WorkspaceAbstractView.swift (25 lines)
struct WorkspaceAbstractView: View {
  let variant: WorkspacePlatformVariant
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    switch variant {
    case .ios:   WorkspaceIOSView(context: context, bindings: bindings)
    case .ipad:  WorkspaceIPadView(context: context, bindings: bindings)
    case .mac:   WorkspaceMacView(context: context, bindings: bindings)
    }
  }
}
```

`OnboardingAbstractView` is identical. These files do nothing except delegate.

### Why This Is a Problem

Refactoring.Guru: *"If a class performs only one action, delegating work to another class, why does it exist at all?"*

- Adds an unnecessary layer in the view hierarchy
- Makes stack traces and SwiftUI view introspection harder to read

### Recommended Fix

**Remove Middle Man** pattern.

Inline the switch directly into `WorkspaceView.body` or use a factory method:

```swift
@ViewBuilder
private func platformContent(for variant: WorkspacePlatformVariant) -> some View {
  switch variant {
  case .ios:  WorkspaceIOSView(...)
  case .ipad: WorkspaceIPadView(...)
  case .mac:  WorkspaceMacView(...)
  }
}
```

Or eliminate entirely by collapsing platform trees (see Speculative Generality fix).

---

## 9. Shotgun Surgery (Medium)

**Ref.Guru:** https://refactoring.guru/smells/shotgun-surgery

### Evidence

Adding a new platform (e.g., visionOS) requires changes to:

1. `WorkspacePlatformVariant` enum (+1 case)
2. `OnboardingPlatformVariant` enum (+1 case)
3. `WorkspaceRenderContext` - add case to ~20 computed properties
4. `OnboardingRenderContext` - if it had layout values
5. `WorkspaceAbstractView` - add case to switch
6. `OnboardingAbstractView` - add case to switch
7. `WorkspaceView` - platform detection logic
8. `OnboardingView` - platform detection logic
9. Create `Views/visionOS/` folder with 4+ files
10. `WorkspacePreviewSupport` - add variant parameter support
11. `OnboardingPreviewSupport` - add variant parameter support

### Why This Is a Problem

Refactoring.Guru: *"Making any modifications requires that you make many small changes to many different classes."*

### Recommended Fix

**Move Method** + **Consolidate Duplicate Conditional Fragments**.

Use runtime adaptive layout (size classes, geometry) instead of compile-time platform variants. If platform-specific code is truly needed, centralize the dispatch in ONE factory/registry:

```swift
enum PlatformViewFactory {
  static func workspaceView(state: WorkspaceState) -> some View {
    #if os(macOS)
      WorkspaceMacView(state: state)
    #elseif os(iOS)
      if UIDevice.current.userInterfaceIdiom == .pad {
        WorkspaceIPadView(state: state)
      } else {
        WorkspaceIOSView(state: state)
      }
    #endif
  }
}
```

---

## 10. Primitive Obsession (Low)

**Ref.Guru:** https://refactoring.guru/smells/primitive-obsession

### Evidence

```swift
enum WorkspaceQuickPrompt: String, CaseIterable, Hashable, Identifiable {
  case toDoList = "Write a to-do list for a personal project"
  case emailReply = "Generate an email to reply to a job offer"
  // ...
  var symbolName: String { ... }
}

enum WorkspaceModel: String, CaseIterable, Identifiable {
  case chatGPT4o = "ChatGPT 4o"
  // ...
}
```

Using `rawValue` string for display text conflates:
- Machine identifier
- User-facing display text
- Prompt content text

### Why This Is a Problem

Refactoring.Guru: *"Use of primitives instead of small objects for simple tasks... makes the code less flexible."*

- Cannot localize without breaking identifiers
- Cannot add metadata (description, icon, category) without enum bloat

### Recommended Fix

**Replace Data Value with Object** pattern.

```swift
struct QuickPrompt: Identifiable, Hashable {
  let id: String
  let title: String
  let symbolName: String
  let promptText: String
}

extension QuickPrompt {
  static let toDoList = QuickPrompt(
    id: "to-do-list",
    title: "Write a to-do list for a personal project",
    symbolName: "person",
    promptText: "Write a to-do list for a personal project"
  )
}
```

---

## Build Impact Analysis

The `spm-build-analysis` skill identifies these build-time smells:

1. **Swift macro rebuild cascade**: TCA -> swift-syntax macros cause near-full rebuilds on trivial changes
2. **Transitive dependency bloat**: 15+ modules downloaded/compiled for a dependency that is unused
3. **Multi-file invalidation**: 2,800+ lines of duplicated platform code means wider incremental rebuild scope

**Estimated clean build impact**: Removing unused TCA + collapsing duplicates could reduce clean build time by 30-50%.

---

## Next Steps

1. Read `/docs/refactoring-plan.md` for the proposed folder structure and migration path
2. Apply fixes in priority order: Dead Code -> Duplicate Code -> Large Class -> Switch Statements
3. Run build benchmark before and after using `xcode-build-benchmark` skill
4. Add SwiftLint or SwiftFormat rules to prevent regressions
