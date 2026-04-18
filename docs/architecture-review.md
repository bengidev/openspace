# OpenSpace Architecture Review

This document describes the architecture that fits the repository **as it exists now** after the onboarding-focused refactor.

## Summary

The previous architecture document was far ahead of the codebase. It proposed TCA, Clean Architecture, repositories, DTOs, and provider layers that do not exist in this repository yet.

That mismatch made the project harder to trust.

The current architecture intentionally does less:

- one lightweight app root
- one onboarding feature
- one minimal post-onboarding placeholder
- one shared theme file
- one platform-specific onboarding render tree split into small files per Apple platform

This is the correct level of structure for the current prototype.

## Current Architecture

```text
OpenSpaceApp
  -> AppRootView
       -> OnboardingView
            -> OnboardingAbstractView
                 -> Views/iOS/OnboardingIOSView
                 -> Views/iPad/OnboardingIPadView
                 -> Views/Mac/OnboardingMacView
       -> WorkspacePlaceholderView
```

### Responsibilities

- `OpenSpaceApp`
  Creates the app scene and applies the global theme.

- `AppRootView`
  Owns app-level presentation state for first-run flow using `@AppStorage("hasCompletedOnboarding")`.

- `OnboardingView`
  Owns the first-run facade, shared onboarding state, and handoff into the platform-specific render tree.

- `OnboardingAbstractView`
  Resolves the active Apple-platform implementation and hands off to the concrete onboarding subtree for that platform.

- `Features/Onboarding/Views/iOS`, `Views/iPad`, `Views/Mac`
  Hold the concrete onboarding implementations. Each platform folder can contain multiple small subviews such as root layout, header, hero, and footer.

- `Features/Onboarding/Views/Shared`
  Holds reusable onboarding UI parts and supporting types that should stay consistent across platform implementations.

- `OnboardingVisuals`
  Holds reusable visual building blocks for the onboarding surface.

- `WorkspacePlaceholderView`
  Keeps the app honest after onboarding finishes. It is not pretending to be a finished workspace yet.

- `ThemeColors`
  Centralizes color tokens and shared styling helpers.

## Why This Is Better

### 1. It matches the actual product scope

The repository is currently about refining onboarding direction, not about delivering a full AI workspace.

### 2. It avoids premature architecture

There is no current need for:

- TCA reducers
- repository abstractions
- SwiftData DTO mapping
- dependency injection frameworks
- navigation coordinators

Those layers would mostly add ceremony right now.

The exception is platform rendering inside onboarding. Since the app already targets iPhone, iPad, and macOS in one codebase, a facade plus abstract platform handoff is justified: it lets the feature keep one shared state flow while each platform owns its own composable view subtree.

### 3. It keeps the next refactor obvious

When the workspace shell becomes real, the next architectural split is clear:

- `App/`
  App entry and root flow
- `Features/Onboarding/`
  First-run experience
- `Features/Workspace/`
  Real post-onboarding product surface
- `Shared/Theme/`
  Design tokens and reusable styling

That evolution can happen when the code actually needs it.

## Recommended Folder Direction

The repository now has the basic lightweight split in place. As more screens are added, keep evolving in this direction:

```text
OpenSpace/
├── App/
│   ├── OpenSpaceApp.swift
│   └── AppRootView.swift
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── Views/
│   │   │   ├── OnboardingAbstractView.swift
│   │   │   ├── Shared/
│   │   │   │   ├── OnboardingPlatformVariant.swift
│   │   │   │   ├── OnboardingRenderContext.swift
│   │   │   │   └── OnboardingSharedComponents.swift
│   │   │   ├── iOS/
│   │   │   ├── iPad/
│   │   │   └── Mac/
│   │   └── OnboardingVisuals.swift
│   └── Workspace/
│       └── WorkspacePlaceholderView.swift
└── Shared/
    └── Theme/
        └── ThemeColors.swift
```

That remains enough structure for the next stage without importing heavyweight patterns too early. If more multiplatform features start to diverge in render trees the same way, the onboarding pattern can be repeated feature-by-feature instead of pushing platform branches into the entire app root.

## Architectural Rules For The Next Phase

- Keep app-level flow state in one place.
- Keep onboarding visuals separate from onboarding flow state.
- Keep multiplatform render variation below the feature container, not above it.
- Use one facade entry and one abstract platform handoff per feature before branching into concrete platform folders.
- When one feature subview becomes large, split that subview into its own `Views/<Part>/` folder with separate concrete files per platform.
- Do not introduce persistence until real data needs to survive app launches.
- Do not introduce TCA unless multiple interacting features and async effects make state coordination hard to reason about.
- Keep documentation aligned with the code that actually exists.

## Immediate Next Step

The next meaningful architectural addition is not a data layer. It is a real post-onboarding workspace shell with explicit product goals.

Until that exists, the current lightweight structure is the correct one.
