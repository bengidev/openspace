# Current State

This document describes the repository as it exists today, based on the current source tree.

## Summary

OpenSpace is currently an **early starter app**, not yet an AI product. The codebase is still very close to the default Xcode template for a SwiftUI + SwiftData application.

## What Exists Today

### App target

- [OpenSpace/OpenSpaceApp.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/OpenSpaceApp.swift:11)
  Defines the `@main` app entry point and creates a SwiftData `ModelContainer` for `Item`.

- [OpenSpace/ContentView.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/ContentView.swift:10)
  Implements the starter UI:
  a list of timestamps, add button, delete behavior, and a simple navigation detail screen.

- [OpenSpace/Item.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace/Item.swift:10)
  Defines the only current domain model, `Item`, with a single `timestamp` property.

### Tests

- [OpenSpaceTests/OpenSpaceTests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceTests/OpenSpaceTests.swift:8)
  Default Swift Testing template with a placeholder test.

- [OpenSpaceUITests/OpenSpaceUITests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceUITests/OpenSpaceUITests.swift:10)
  Default UI test template.

- [OpenSpaceUITests/OpenSpaceUITestsLaunchTests.swift](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceUITests/OpenSpaceUITestsLaunchTests.swift:10)
  Default launch test template.

## Platform And Stack

From the project configuration:

- iOS deployment target: `17.6`
- macOS deployment target: `14.6`
- UI framework: `SwiftUI`
- persistence layer: `SwiftData`
- test frameworks: `Swift Testing` and `XCTest`

## What Does Not Exist Yet

The following capabilities are **not present** in the repository right now:

- AI provider clients
- API request layer
- BYOK credentials
- Keychain storage
- chat messages or conversation models
- streaming responses
- model selection
- provider switching
- TCA reducers or store structure
- product-grade chat or workspace UI

## Practical Interpretation

The best way to understand this repository today is:

> A clean SwiftUI starter project intended to grow into an AI workspace app, but still at the foundation stage.

That makes it a good place to start architecture and product work, but the current code should not be documented as though those product features already exist.
