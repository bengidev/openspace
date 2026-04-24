# OpenSpace Refactoring Examples

Concrete before/after code for the highest-impact smells.

---

## 1. Duplicate Code → Extract Method (Workspace SurfaceChip)

**Smell:** Duplicate Code  
**Pattern:** Extract Method  
**File:** `Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift`

### Before (repeated in 3 files)

```swift
// WorkspaceIOSContentViews.swift
private struct WorkspaceIOSSurfaceChip: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let systemImage: String

  var body: some View {
    Button {} label: {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.system(size: 13, weight: .semibold))
        Text(title)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(WorkspacePalette.primaryText)
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(
        Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme))
      )
      .overlay(
        Capsule().stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}

// WorkspaceIPadContentViews.swift → identical code, named WorkspaceIPadSurfaceChip
// WorkspaceMacContentViews.swift → identical code, named WorkspaceMacSurfaceChip
```

### After (one shared struct)

```swift
// Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift
struct WorkspaceSurfaceChip: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let systemImage: String

  var body: some View {
    Button {} label: {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.system(size: 13, weight: .semibold))
        Text(title)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(WorkspacePalette.primaryText)
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(
        Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme))
      )
      .overlay(
        Capsule().stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}
```

**Lines saved:** ~75 (25 × 3 → 25)

---

## 2. Duplicate Code → Form Template Method (Workspace MainContent)

**Smell:** Duplicate Code  
**Pattern:** Form Template Method  
**File:** `Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift`

### Before (3 files, ~60 lines each)

```swift
// WorkspaceIOSContentViews.swift
struct WorkspaceIOSMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
      WorkspaceIOSUtilityBar(context: context, bindings: bindings)
        .accessibilityIdentifier("workspace.ios.topbar")

      WorkspaceIOSCompactNavigation(selectedDestination: bindings.selectedDestination)

      VStack(spacing: context.heroSectionSpacing) {
        WorkspaceIOSHeroOrb(context: context)
        WorkspaceIOSHeroHeading(context: context, destination: bindings.selectedDestination.wrappedValue)
        Text(bindings.selectedDestination.wrappedValue.heroBody)
          .font(.body)
        WorkspaceIOSComposerCard(context: context, bindings: bindings)
        WorkspaceIOSQuickPromptSection(context: context, bindings: bindings)
      }
      .frame(maxWidth: .infinity)
      .padding(.top, context.heroTopSpacing)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, context.mainHorizontalPadding)
    .padding(.vertical, context.mainVerticalPadding)
  }
}

// WorkspaceIPadContentViews.swift → repeats with IPad prefix + conditional compact nav
// WorkspaceMacContentViews.swift → repeats with Mac prefix, no compact nav
```

### After (shared template)

```swift
// Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift
struct WorkspaceMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  private var selectedDestination: WorkspaceDestination {
    bindings.selectedDestination.wrappedValue
  }

  var body: some View {
    VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
      WorkspaceUtilityBar(context: context, bindings: bindings)
        .accessibilityIdentifier("\(context.variant.identifierPrefix).topbar")

      if shouldShowCompactNav {
        WorkspaceCompactNavigation(selectedDestination: bindings.selectedDestination)
      }

      VStack(spacing: context.heroSectionSpacing) {
        WorkspaceHeroOrb(context: context)
        WorkspaceHeroHeading(context: context, destination: selectedDestination)
        Text(selectedDestination.heroBody)
          .font(context.heroBodyFont)
        WorkspaceComposerCard(context: context, bindings: bindings)
        WorkspaceQuickPromptSection(context: context, bindings: bindings)
      }
      .frame(maxWidth: .infinity)
      .padding(.top, context.heroTopSpacing)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, context.mainHorizontalPadding)
    .padding(.vertical, context.mainVerticalPadding)
  }

  private var shouldShowCompactNav: Bool {
    switch context.variant {
    case .ios: true
    case .ipad: !context.usesSidebar
    case .mac: false
    }
  }
}
```

**Lines saved:** ~120 (60 × 3 → ~60)

---

## 3. Duplicate Code → Extract Method (Workspace ComposerCard)

**Smell:** Duplicate Code  
**Pattern:** Extract Method + Move Metric to Context  
**File:** `Features/Workspace/Views/Shared/WorkspaceSharedContentViews.swift`

### Before (iOS excerpt)

```swift
private struct WorkspaceIOSComposerCard: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let destination: WorkspaceDestination
  @Binding var selectedWritingStyle: WorkspaceWritingStyle
  @Binding var citationEnabled: Bool
  @Binding var selectedPrompt: String
  @FocusState.Binding var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      ZStack(alignment: .topLeading) {
        if selectedPrompt.isEmpty {
          Text(destination.composerPlaceholder)
            .font(.body)
            .foregroundStyle(WorkspacePalette.tertiaryText(for: colorScheme))
        }
        TextField("", text: $selectedPrompt, axis: .vertical)
          .font(.body)
          .lineLimit(4...6)
      }
      .frame(minHeight: 110, alignment: .topLeading)

      ViewThatFits(in: .horizontal) {
        primaryControlRow
        compactControlStack
      }
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 26, style: .continuous)
        .fill(WorkspacePalette.panelBackground(for: colorScheme))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 26, style: .continuous)
        .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
    )
  }
}
```

### After (context-driven)

```swift
struct WorkspaceComposerCard: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let destination: WorkspaceDestination
  @Binding var selectedWritingStyle: WorkspaceWritingStyle
  @Binding var citationEnabled: Bool
  @Binding var selectedPrompt: String
  @FocusState.Binding var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: context.composerVStackSpacing) {
      ZStack(alignment: .topLeading) {
        if selectedPrompt.isEmpty {
          Text(destination.composerPlaceholder)
            .font(context.composerTextFont)
            .foregroundStyle(WorkspacePalette.tertiaryText(for: colorScheme))
        }
        TextField("", text: $selectedPrompt, axis: .vertical)
          .font(context.composerTextFont)
          .lineLimit(context.composerLineLimit)
      }
      .frame(minHeight: context.composerMinHeight, alignment: .topLeading)

      if context.composerUsesCompactFallback {
        ViewThatFits(in: .horizontal) {
          primaryControlRow
          compactControlStack
        }
      } else {
        primaryControlRow
      }
    }
    .padding(context.composerPadding)
    .background(
      RoundedRectangle(cornerRadius: context.composerCornerRadius, style: .continuous)
        .fill(WorkspacePalette.panelBackground(for: colorScheme))
    )
    .overlay(
      RoundedRectangle(cornerRadius: context.composerCornerRadius, style: .continuous)
        .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
    )
  }
}
```

**Lines saved:** ~200 (110 × 3 → ~110, plus removed hardcoded values)

---

## 4. Middle Man → Remove Middle Man (OnboardingAbstractView)

**Smell:** Middle Man  
**Pattern:** Remove Middle Man  
**File:** `Features/Onboarding/OnboardingView.swift`

### Before

```swift
// OnboardingAbstractView.swift
struct OnboardingAbstractView: View {
  let variant: OnboardingPlatformVariant
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  var body: some View {
    switch variant {
    case .ios:
      OnboardingIOSView(context: context, onContinue: onContinue)
    case .ipad:
      OnboardingIPadView(context: context, onContinue: onContinue)
    case .mac:
      OnboardingMacView(context: context, onContinue: onContinue)
    }
  }
}

// OnboardingView.swift
var body: some View {
  OnboardingAbstractView(
    variant: currentVariant,
    context: renderContext,
    onContinue: { viewStore.send(.continueButtonTapped) }
  )
}
```

### After

```swift
// Delete OnboardingAbstractView.swift entirely

// OnboardingView.swift
var body: some View {
  switch currentVariant {
  case .ios, .ipad:
    OnboardingMobileView(
      variant: currentVariant,
      context: renderContext,
      onContinue: { viewStore.send(.continueButtonTapped) }
    )
  case .mac:
    OnboardingMacView(
      context: renderContext,
      onContinue: { viewStore.send(.continueButtonTapped) }
    )
  }
}
```

**Lines saved:** ~25 (entire file deleted)

---

## 5. Duplicate Code → Extract Class (Onboarding Footer Proxies)

**Smell:** Duplicate Code + Middle Man  
**Pattern:** Extract Class  
**File:** `Features/Onboarding/Views/Shared/OnboardingSharedViews.swift`

### Before (3 proxy files)

```swift
// OnboardingIOSFooterView.swift
struct OnboardingIOSFooterView: View {
  let labels: [String]
  var body: some View {
    OnboardingMetadataBar(labels: labels, alignment: .center)
      .accessibilityIdentifier("onboarding.ios.footer")
  }
}

// OnboardingIPadFooterView.swift
struct OnboardingIPadFooterView: View {
  let labels: [String]
  var body: some View {
    OnboardingMetadataBar(labels: labels, alignment: .leading)
      .accessibilityIdentifier("onboarding.ipad.footer")
  }
}

// OnboardingMacFooterView.swift
struct OnboardingMacFooterView: View {
  let labels: [String]
  var body: some View {
    OnboardingMetadataBar(labels: labels, alignment: .leading)
      .accessibilityIdentifier("onboarding.mac.footer")
  }
}
```

### After (one parameterized view)

```swift
// Features/Onboarding/Views/Shared/OnboardingSharedViews.swift
struct OnboardingFooterView: View {
  let labels: [String]
  let alignment: HorizontalAlignment
  let identifierPrefix: String

  var body: some View {
    OnboardingMetadataBar(labels: labels, alignment: alignment)
      .accessibilityIdentifier("\(identifierPrefix).footer")
  }
}
```

Usage:
```swift
OnboardingFooterView(
  labels: ["Secure", "Private", "Fast"],
  alignment: variant == .ios ? .center : .leading,
  identifierPrefix: variant.identifierPrefix
)
```

**Lines saved:** ~80 (36 + 37 + 36 → ~22)

---

## 6. Large Class → Extract Class (ThemeColors.swift)

**Smell:** Large Class / God Object  
**Pattern:** Extract Class  
**Files:** `Shared/Theme/DesignTokens.swift`, `Shared/Theme/Color+Hex.swift`, `Shared/Theme/ThemeColor.swift`

### Before (264 lines, mixed concerns)

```swift
// Shared/Theme/ThemeColors.swift
import Foundation
import SwiftUI
#if canImport(UIKit)
  import UIKit
#endif

struct AppTheme {
  static let colorHuntInk = Color(hex: "0B0B0B")
  // ... more constants + gradients
}

extension Color {
  init(hex: String) { /* 20 lines */ }
}

enum ThemeColor {
  static func surface(for colorScheme: ColorScheme) -> Color { /* ... */ }
  // ... 40+ static color functions
}
```

### After (3 focused files)

```swift
// Shared/Theme/Color+Hex.swift
import SwiftUI

extension Color {
  init(hex: String) {
    let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    Scanner(string: sanitized).scanHexInt64(&value)
    // ...
  }
}

// Shared/Theme/DesignTokens.swift
import SwiftUI

struct AppTheme {
  static let colorHuntInk = Color(hex: "0B0B0B")
  static let colorHuntInkRaised = Color(hex: "171717")
  static let vanillaCream = Color(hex: "E9E3DF")
  static let vanillaCreamMuted = Color(hex: "D8D2CF")

  static let primaryGradient = LinearGradient(
    colors: [colorHuntInkRaised, vanillaCream],
    startPoint: .topLeading, endPoint: .bottomTrailing
  )
}

// Shared/Theme/ThemeColor.swift
import SwiftUI

enum ThemeColor {
  static func surface(for colorScheme: ColorScheme) -> Color { /* ... */ }
  static func chromeStroke(for colorScheme: ColorScheme) -> Color { /* ... */ }
  // ... remaining semantic colors
}
```

**Benefit:** No line savings, but each file has a single responsibility and imports only what it needs.

---

## 7. Duplicate Code → Form Template Method (Onboarding Mobile View)

**Smell:** Duplicate Code  
**Pattern:** Form Template Method  
**File:** `Features/Onboarding/Views/OnboardingMobileView.swift`

### Before (2 separate files)

```swift
// OnboardingIOSView.swift (174 lines)
struct OnboardingIOSView: View {
  let context: OnboardingRenderContext
  let onContinue: () -> Void
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 18) {
        Spacer(minLength: 20)
        OnboardingHeroPanel(style: .floatingShowcase, cornerRadius: 32) {
          VStack(spacing: 0) {
            OnboardingIOSHeader()
            OnboardingIOSPanel(...) { /* capability chips */ }
            OnboardingIOSCapabilityStrip(...)
            OnboardingIOSSupportingNote(...)
          }
        }
        OnboardingContinueButton(action: onContinue)
        OnboardingIOSFooterView(labels: ["Secure", "Private", "Fast"])
      }
    }
  }
}

// OnboardingIPadView.swift (180 lines) → identical structure, IPad prefix + 2 extra chips
```

### After (unified mobile view)

```swift
struct OnboardingMobileView: View {
  let variant: OnboardingPlatformVariant
  let context: OnboardingRenderContext
  let onContinue: () -> Void

  private var capabilityChips: [String] {
    switch variant {
    case .ios: ["Code", "Images", "Research", "Automation"]
    case .ipad: ["Code", "Images", "Research", "Automation", "Vision", "Agents"]
    case .mac: []
    }
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 18) {
        Spacer(minLength: 20)
        OnboardingHeroPanel(style: .floatingShowcase, cornerRadius: 32) {
          VStack(spacing: 0) {
            OnboardingMobileHeaderView(variant: variant)
            OnboardingAnimatedPanel(context: context) {
              /* capability chips */
            }
            OnboardingCapabilityStrip(chips: capabilityChips)
            OnboardingSupportingNote(
              text: context.supportingNote,
              alignment: variant == .ios ? .center : .leading
            )
          }
        }
        OnboardingContinueButton(action: onContinue)
        OnboardingFooterView(
          labels: ["Secure", "Private", "Fast"],
          alignment: variant == .ios ? .center : .leading,
          identifierPrefix: variant.identifierPrefix
        )
      }
    }
  }
}
```

**Lines saved:** ~154 (174 + 180 → ~200)

---

## Summary of Patterns Used

| Example | Smell | Refactoring Pattern | Est. Lines Saved |
|---|---|---|---|
| 1. SurfaceChip | Duplicate Code | Extract Method | ~50 |
| 2. MainContent | Duplicate Code | Form Template Method | ~120 |
| 3. ComposerCard | Duplicate Code | Extract Method + Move Field | ~200 |
| 4. AbstractView | Middle Man | Remove Middle Man | ~25 |
| 5. Footer Proxies | Duplicate Code + Middle Man | Extract Class | ~80 |
| 6. ThemeColors | Large Class | Extract Class | 0 (clarity gain) |
| 7. Mobile View | Duplicate Code | Form Template Method | ~154 |
