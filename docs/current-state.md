# Current State

This document describes the repository as it exists today, based on the current source tree.

## Summary

OpenSpace is currently an **onboarding-first SwiftUI prototype**, not yet an AI product. The codebase now centers on a first-run visual experience and a minimal post-onboarding placeholder instead of the old sample timestamp list.

## What Exists Today

### App target

- [OpenSpace/OpenSpaceApp.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/OpenSpaceApp.swift:9)
  Defines the `@main` app entry point and applies the shared OpenSpace theme.

- [OpenSpace/AppRootView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/AppRootView.swift:8)
  Owns the lightweight app flow. It switches between onboarding and a placeholder shell using `@AppStorage("hasCompletedOnboarding")`.

- [OpenSpace/OnboardingView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/OnboardingView.swift:10)
  Implements the first-run onboarding experience inspired by the provided visual concept.

- [OpenSpace/OnboardingVisuals.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/OnboardingVisuals.swift:10)
  Contains reusable onboarding visuals such as the atmospheric backdrop, hero panel, and pinstripe texture.

- [OpenSpace/WorkspacePlaceholderView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/WorkspacePlaceholderView.swift:8)
  Provides a deliberately minimal screen after onboarding completes, keeping the repo honest about what has not been built yet.

- [OpenSpace/Theme/ThemeColors.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Theme/ThemeColors.swift:10)
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
- product-grade workspace shell after onboarding

## Practical Interpretation

The best way to understand this repository today is:

> A SwiftUI prototype for refining OpenSpace's first-run onboarding direction before building the real AI workspace underneath it.

That makes it a good place to iterate on product framing and visual language, but not yet a foundation for documenting provider features or a full app architecture.
