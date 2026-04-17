# Product Direction

This document translates the original OpenSpace vision into a roadmap that fits the current repository state.

## Intended Product

OpenSpace aims to become a native Apple-platform workspace for interacting with multiple AI providers through a local-first, bring-your-own-key model.

That vision is still valid. It just needs to be described as a **roadmap**, not as already-implemented functionality.

## Recommended Evolution Path

### 1. Introduce real workspace models

Move from the current onboarding-only prototype to application-specific models such as:

- `Provider`
- `Conversation`
- `Message`
- `WorkspaceSettings`
- `StoredCredentialReference`

### 2. Introduce local credential management

Before adding provider networking, establish a secure local credential layer:

- save keys in Keychain
- model provider configuration separately from chat data
- keep the app usable even when only some providers are configured

### 3. Add a provider abstraction layer

Avoid wiring UI directly to provider-specific APIs. Add a small service boundary first:

- provider capability model
- request/response mapping
- error normalization
- streaming support hooks

### 4. Replace the placeholder post-onboarding shell

The current onboarding flow should eventually hand off into a real workspace shell:

- sidebar or conversation list
- thread detail view
- composer input
- provider and model controls
- local settings and credential screens

### 5. Reassess architecture after real complexity exists

The repo does not currently use TCA, and that is fine at this stage. Add stronger architecture boundaries when the app actually has:

- multi-screen state
- async networking
- streaming updates
- provider-specific behavior
- richer persistence rules

If TCA is still the preferred choice then, introduce it on top of concrete product needs rather than as a premature dependency.

## Documentation Guidance

Future documentation for OpenSpace should keep three layers separate:

### Current implementation

What exists in the repository now.

### Near-term roadmap

What is likely to be built next from the existing onboarding baseline.

### Long-term vision

What the full OpenSpace product is intended to become.

Keeping those layers separate will make the repo easier to trust and easier to contribute to.
