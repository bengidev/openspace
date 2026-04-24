# OpenSpace 🌌

**A native Apple-platform starter for a future multi-provider AI workspace.**

[![macOS](https://img.shields.io/badge/macOS-14.6%2B-blue.svg)](https://apple.com/macos)
[![iOS](https://img.shields.io/badge/iOS-17.6%2B-blue.svg)](https://apple.com/ios)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-orange.svg)](https://developer.apple.com/xcode/swiftui/)
[![Testing](https://img.shields.io/badge/Testing-Swift%20Testing-lightgrey.svg)](https://developer.apple.com/documentation/testing)

OpenSpace is intended to become a native workspace for chatting with multiple AI providers through a local-first, bring-your-own-key approach.

The repository does **not** implement that product yet. The current codebase is a SwiftUI prototype centered on a first-run onboarding experience and a minimal placeholder shell after onboarding completes.

## Current State

- Built with **SwiftUI**
- Targets **iOS 17.6+** and **macOS 14.6+**
- Uses The Composable Architecture (TCA) for app, onboarding, and workspace state
- Includes starter tests with **Swift Testing** and **XCTest UI Testing**
- Focuses on onboarding visuals, not on a real AI workspace yet

## What This Repo Is Not Yet

- Not a production AI client
- Not a multi-provider chat workspace
- Uses TCA for current feature flow and state management
- Not storing API keys in Keychain
- Not integrating provider SDKs or persistence models yet

## Repository Layout

- [OpenSpace](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpace) contains the app source
- [OpenSpaceTests](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceTests) contains the starter Swift Testing target
- [OpenSpaceUITests](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/OpenSpaceUITests) contains the starter UI test target
- [docs/current-state.md](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/docs/current-state.md) documents the repository as it exists today
- [docs/product-direction.md](/Users/beng/Documents/iOS%20Projects/OpenSpace/OpenSpace/docs/product-direction.md) describes a realistic path toward the intended product

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/YOUR_USERNAME/OpenSpace.git
   cd OpenSpace
   ```
2. Open `OpenSpace.xcodeproj` in Xcode
3. Run the `OpenSpace` scheme on iOS Simulator or macOS
4. Iterate on the onboarding prototype before introducing real workspace and provider layers

## Documentation Notes

This documentation intentionally separates:

- **Current state**: what the repository actually contains today
- **Product direction**: what OpenSpace may become as development continues

That separation matters here because the original product description was ahead of the codebase.
