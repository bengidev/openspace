# Current State

This document describes the repository as it exists today, based on the current source tree.

## Summary

OpenSpace is currently an **onboarding-first SwiftUI prototype** with an early workspace shell, not yet a full AI product. The codebase now centers on a first-run visual experience and a styled post-onboarding canvas instead of the old sample timestamp list.

## What Exists Today

### App target

- [OpenSpace/App/OpenSpaceApp.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/App/OpenSpaceApp.swift:11)
  Defines the `@main` app entry point and applies the shared OpenSpace theme.

- [OpenSpace/App/AppRootView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/App/AppRootView.swift:10)
  Owns the lightweight app flow. It switches between onboarding and the early workspace shell using `@AppStorage("hasCompletedOnboarding")`.

- [OpenSpace/Features/Onboarding/OnboardingView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Onboarding/OnboardingView.swift:10)
  Acts as the onboarding facade. It owns shared feature state and hands rendering off to the onboarding abstract view.

- [OpenSpace/Features/Onboarding/Views/OnboardingAbstractView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Onboarding/Views/OnboardingAbstractView.swift:10)
  Routes the feature into the concrete iPhone, iPad, or macOS onboarding implementation.

- [OpenSpace/Features/Onboarding/Views](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Onboarding/Views)
  Holds the composable multiplatform onboarding tree. Each platform now has its own sub-folder (`iOS`, `iPad`, `Mac`) containing multiple small views instead of one large platform block.

- [OpenSpace/Features/Onboarding/Views/Shared](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Onboarding/Views/Shared)
  Contains shared onboarding types and reusable UI pieces such as render context, panel wrapper, chips, buttons, and motion helpers.

- [OpenSpace/Features/Onboarding/OnboardingVisuals.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Onboarding/OnboardingVisuals.swift:9)
  Contains reusable onboarding visuals such as the atmospheric backdrop, hero panel, and pinstripe texture.

- [OpenSpace/Features/Workspace/WorkspaceView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Workspace/WorkspaceView.swift:10)
  Acts as the workspace facade. It owns local workspace state, applies the shared backdrop, and hands rendering off into the workspace platform tree.

- [OpenSpace/Features/Workspace/Views](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Features/Workspace/Views)
  Mirrors the onboarding feature split with an abstract platform handoff, shared components, and concrete iPhone, iPad, and macOS workspace implementations. The current refinement focus is the macOS surface first, with mobile variants kept as temporary fallbacks.

- [OpenSpace/Shared/Theme/ThemeColors.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Shared/Theme/ThemeColors.swift:10)
  Defines theme tokens and shared view styling helpers.

### Tests

- [OpenSpaceTests/OpenSpaceTests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceTests/OpenSpaceTests.swift:8)
  Default Swift Testing template with a placeholder test.

- [OpenSpaceUITests/OpenSpaceUITests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceUITests/OpenSpaceUITests.swift:10)
  Default UI test template.

- [OpenSpaceUITests/OpenSpaceUITestsLaunchTests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceUITests/OpenSpaceUITestsLaunchTests.swift:10)
  Default launch test template.

## Platform And Stack

From the project configuration and current source:

- iOS deployment target: `17.6`
- macOS deployment target: `14.6`
- UI framework: `SwiftUI`
- local state for onboarding completion: `@AppStorage`
- test frameworks: `Swift Testing` and `XCTest`

## What Does Not Exist Yet

The following capabilities are **not present** in the repository right now:

- AI provider clients
- API request layer
- BYOK credential storage
- Keychain integration
- conversation or message domain models
- persistence for real workspace data
- onboarding analytics or experiment framework
- product-grade, data-driven workspace after onboarding

## Practical Interpretation

The best way to understand this repository today is:

> A SwiftUI prototype for refining OpenSpace's first-run onboarding direction while shaping the first pass of the real workspace shell underneath it.

That makes it a good place to iterate on product framing and visual language, but not yet a foundation for documenting provider features or a full app architecture.
