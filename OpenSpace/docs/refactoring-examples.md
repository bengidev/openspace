# Refactoring Examples

> Concrete before/after code for the highest-impact smells

---

## Example 1: Replace Switch-Heavy RenderContext with Polymorphism

### Before: `WorkspaceRenderContext.swift` (247 lines)

```swift
struct WorkspaceRenderContext {
  let variant: WorkspacePlatformVariant
  let containerSize: CGSize
  let hasAppeared: Bool
  let reduceMotion: Bool

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
  // ... 18 more switch statements
}
```

**Smells:** Switch Statements, Shotgun Surgery

### After: `WorkspaceLayoutProfile.swift` + `PlatformProfiles.swift` (~80 lines total)

```swift
protocol WorkspaceLayoutProfile {
  var containerSize: CGSize { get }
  var shellMaxWidth: CGFloat { get }
  var shellHorizontalPadding: CGFloat { get }
  // ... other properties
}

struct IOSLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize
  var shellMaxWidth: CGFloat { 760 }
  var shellHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.038, 16), 22)
  }
}

struct IPadLayoutProfile: WorkspaceLayoutProfile {
  let containerSize: CGSize
  var shellMaxWidth: CGFloat { 1380 }
  var shellHorizontalPadding: CGFloat {
    min(max(containerSize.width * 0.03, 18), 32)
  }
}
```

**Benefit:** Adding visionOS requires one new struct, not 20 new switch cases.

---

## Example 2: Replace Data Clump with @Observable

### Before: `WorkspaceView.swift` + `WorkspaceViewBindings`

```swift
struct WorkspaceView: View {
  @State private var selectedDestination: WorkspaceDestination = .home
  @State private var selectedModel: WorkspaceModel = .chatGPT4o
  @State private var selectedPrompt = ""
  @State private var selectedWritingStyle: WorkspaceWritingStyle = .balanced
  @State private var citationEnabled = true
  @State private var highlightedQuickPrompt: WorkspaceQuickPrompt?
  @State private var hasAppeared = false

  let replayOnboarding: () -> Void

  private var bindings: WorkspaceViewBindings {
    WorkspaceViewBindings(
      selectedDestination: $selectedDestination,
      selectedModel: $selectedModel,
      selectedPrompt: $selectedPrompt,
      selectedWritingStyle: $selectedWritingStyle,
      citationEnabled: $citationEnabled,
      highlightedQuickPrompt: $highlightedQuickPrompt,
      isPromptFocused: $isPromptFocused,
      replayOnboarding: replayOnboarding
    )
  }
}

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

**Smells:** Data Clumps, Long Parameter List

### After: `WorkspaceState.swift`

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
  var hasAppeared: Bool = false
  var replayOnboarding: () -> Void = {}
}

struct WorkspaceView: View {
  @State private var state = WorkspaceState()

  var body: some View {
    WorkspaceContentView(profile: profile, state: state)
  }
}
```

**Benefit:** No binding aggregation, no clump propagation through 4 view layers.

---

## Example 3: Collapse 3 Platform Content Views into 1

### Before: 3 files, 1,326 lines

```swift
// WorkspaceIOSContentViews.swift
private struct WorkspaceIOSUtilityBar: View { ... }
private struct WorkspaceIOSHeroOrb: View { ... }
private struct WorkspaceIOSComposerCard: View { ... }

// WorkspaceMacContentViews.swift
private struct WorkspaceMacUtilityBar: View { ... }
private struct WorkspaceMacHeroOrb: View { ... }
private struct WorkspaceMacComposerCard: View { ... }

// WorkspaceIPadContentViews.swift
private struct WorkspaceIPadUtilityBar: View { ... }
private struct WorkspaceIPadHeroOrb: View { ... }
private struct WorkspaceIPadComposerCard: View { ... }
```

**Smells:** Duplicate Code, Alternative Classes with Different Interfaces

### After: `WorkspaceContentView.swift` (~400 lines)

```swift
struct WorkspaceContentView: View {
  let profile: WorkspaceLayoutProfile
  @Bindable var state: WorkspaceState

  var body: some View {
    VStack(alignment: .leading, spacing: profile.mainSectionSpacing) {
      UtilityBar(profile: profile, state: state)
      if !profile.usesSidebar { CompactNavigation(state: state) }
      HeroSection(profile: profile, state: state)
      Spacer()
    }
    .padding(.horizontal, profile.mainHorizontalPadding)
  }
}

// Extracted reusable components (not platform-prefixed)
private struct UtilityBar: View { ... }
private struct HeroOrb: View { ... }
private struct ComposerCard: View { ... }
private struct QuickPromptSection: View { ... }
```

**Benefit:** One source of truth. Bug fix applied once, not 3x.

---

## Example 4: Extract Content from Navigation Enum

### Before: `WorkspaceModels.swift` (embedded strings)

```swift
enum WorkspaceDestination: String, CaseIterable, Hashable {
  case home = "Home"

  var heroFirstLine: String {
    switch self {
    case .home: "Good Afternoon, Bambang"
    // ...
    }
  }

  var heroBody: String {
    switch self {
    case .home: "A calmer desktop workspace..."
    // ...
    }
  }

  var composerPlaceholder: String {
    switch self {
    case .home: "Ask AI a question..."
    // ...
    }
  }
}
```

**Smells:** Large Class, Feature Envy

### After: `WorkspaceContentCatalog.swift`

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
        heroBody: "A calmer desktop workspace for planning...",
        composerPlaceholder: "Ask AI a question or make a request..."
      )
    // ...
    }
  }
}
```

**Usage in view:**

```swift
private var content: WorkspaceContentCatalog.DestinationContent {
  WorkspaceContentCatalog.content(for: state.selectedDestination)
}

Text(content.heroFirstLine)
Text(content.heroBody)
```

**Benefit:** Content writers can edit strings without touching navigation logic.

---

## Example 5: Remove Middle Man AbstractView

### Before: `WorkspaceAbstractView.swift`

```swift
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

**Smells:** Middle Man

### After: Inline in `WorkspaceView`

```swift
struct WorkspaceView: View {
  var body: some View {
    GeometryReader { proxy in
      let profile = layoutProfile(for: proxy.size)
      WorkspaceContentView(profile: profile, state: state)
    }
  }

  private func layoutProfile(for size: CGSize) -> WorkspaceLayoutProfile {
    #if os(macOS)
      MacLayoutProfile(containerSize: size)
    #elseif os(iOS)
      UIDevice.current.userInterfaceIdiom == .pad
        ? IPadLayoutProfile(containerSize: size)
        : IOSLayoutProfile(containerSize: size)
    #endif
  }
}
```

**Benefit:** Removed 2 files (25 lines each) and one unnecessary layer in view hierarchy.

---

## Example 6: Replace Enum RawValue with Struct

### Before: `WorkspaceQuickPrompt`

```swift
enum WorkspaceQuickPrompt: String, CaseIterable, Hashable, Identifiable {
  case toDoList = "Write a to-do list for a personal project"
  case emailReply = "Generate an email to reply to a job offer"

  var id: String { rawValue }

  var symbolName: String {
    switch self {
    case .toDoList: "person"
    case .emailReply: "envelope"
    }
  }
}
```

**Smells:** Primitive Obsession

### After: `QuickPrompt.swift`

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

  static let emailReply = QuickPrompt(
    id: "email-reply",
    title: "Generate an email to reply to a job offer",
    symbolName: "envelope",
    promptText: "Generate an email to reply to a job offer"
  )

  static let all: [QuickPrompt] = [.toDoList, .emailReply, ...]
}
```

**Benefit:** ID is decoupled from display text. Easy to add metadata.
