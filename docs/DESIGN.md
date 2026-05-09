# OpenSpace Onboarding — Visual Design System

Designer-to-developer handoff for the OpenSpace onboarding flow. Primary visual language derives from **Factory.ai** (industrial-modern, monochrome-first, signal-accented, grid-precise). Supporting component patterns, effects, and interaction models are ported from **shadcn/ui**, **Componentry**, **Dot Matrix**, and **Watermelon UI**.

---

## 1. Vision & Philosophy

The OpenSpace onboarding is a **technical workspace introduction**, not a marketing slideshow. It should feel like stepping into a refined industrial command center: vast negative space, precise typography, thin warm-gray borders, and an orange signal that only appears where it means something.

### Five design principles

1. **Monochrome first** — Backgrounds, text, and surfaces live in a near-black to near-white spectrum. The orange accent is a signal, not a decoration.
2. **Stroke over fill** — Cards and containers are defined by thin warm borders on near-black surfaces. Fills are barely there.
3. **Data-dense but breathable** — Small monospace labels, system codes, and metrics sit inside generous grid-based negative space.
4. **Motion is functional** — Animations explain state changes (pairing, typing, queueing, reasoning). No decorative ambient loops.
5. **No scroll** — Every onboarding page must fit entirely within the viewport. Content is sized responsively via `GeometryReader`.

### Visual reference

- **Factory.ai** — near-black `#020202` canvas, warm-gray `#3d3a39` borders, `Geist` sans-serif display type, `Geist Mono` for technical labels, `#ef6f2e` signal accent, 4px/6px/10px radius scale.
- **shadcn/ui** — Component primitives (Button, Card, Badge, Tabs, Slider, Switch) as reference for interaction states, focus rings, and accessible form patterns.
- **Componentry** — Canvas-driven effects (magnet lines, dither gradients, scroll velocity) for hero card micro-interactions. Pointer-reactive animations are allowed **only** inside interactive hero areas, never as ambient background loops.
- **Dot Matrix** — Dot-grid typography and opacity-wave loader patterns for terminal headers and status indicators.
- **Watermelon UI** — Dark documentation shell patterns: sidebar navigation, component card chrome, pill toolbar buttons, preview surface gradients.

---

## 2. Color Palette

### Philosophy

Colors exist in two modes derived from a single token set. Never hardcode hex colors in view code — always route through `OpenSpaceOnboardingPalette`.

### Token table

| Token | Dark | Light | Usage |
|---|---|---|---|
| `background` | `#020202` | `#fafafa` | Root background |
| `backgroundSecondary` | `#101010` | `#eeeeee` | Secondary layer / card inner bg |
| `surface` | `#0a0a0a` | `#ffffff` | Card fill at low opacity |
| `elevatedSurface` | `#161616` | `#f5f5f5` | Elevated hover state |
| `inverseSurface` | `#eeeeee` | `#15130f` | Inverted fills (badges, selected chips) |
| `textPrimary` | `#eeeeee` | `#15130f` | Headlines, body emphasis |
| `textSecondary` | `#a49d9a` | `#5e594f` | Body text, descriptions |
| `textMuted` | `#8a8380` | `#8c8577` | Metadata, labels, hints |
| `border` | `#3d3a39` | `#d8d0c1` | Default stroke |
| `strongBorder` | `#4d4947` | `#b8b3b0` | Emphasized stroke |
| `accent` | `#ef6f2e` | `#d15010` | Signal, active state, primary CTA fill |
| `accentSoft` | `#ee6018` | `#b74816` | Soft accent (hover, glow) |
| `accentText` | `#ffffff` | `#ffffff` | Text on accent background |
| `success` | `#8cffb3` | `#137a42` | Positive state |
| `warning` | `#ffcc7a` | `#a15b08` | Alert, unconfirmed state |
| `primaryActionFill` | `#eeeeee` | `#15130f` | Primary button fill |
| `primaryActionText` | `#020202` | `#fafafa` | Primary button text |

### Color rules

- **Accent coverage** must stay below 10% of any single screen. It is a signal, not a surface.
- **Borders** use `border` at full strength. `strongBorder` is used when an element needs slightly more weight.
- **Surface fills** are almost always combined with opacity (e.g., `palette.surface.opacity(0.5)`). Never use `surface` at 100% on top of `background`.
- **Background is nearly pure black** in dark mode (`#020202`), not a softened gray. This creates the deep, immersive Factory.ai feel.
- **Inverse colors** are used sparingly: selected chip text, final CTA, and lock icon background.

---

## 3. Typography

### Typeface

- **Primary (display & body)**: `.default` atau `Geist`-equivalent sans-serif — headlines, body, buttons, navigation.
- **Mono (technical labels only)**: `.monospaced` — system codes, metric labels, badge titles, status text, command strings.

> Factory.ai uses `Geist` (sans-serif) for almost everything. Monospace is reserved exclusively for small technical annotations (12px system labels). Do not use monospace for headlines or body text.

### Type scale

| Role | Size | Weight | Design | Tracking | Line limit |
|---|---|---|---|---|---|
| Brand label | 12pt | Medium | Sans-serif | normal | 1 |
| Sub-brand | 9pt | Regular | Sans-serif | normal | 1 |
| Page counter | 11pt | Medium | Monospaced | -0.24px | 1 |
| Headline | 28–32pt | Regular (400) | Sans-serif | -1.2px | 2 |
| Body | 13–15pt | Regular | Sans-serif | normal | 3 |
| Metric label | 10pt | Semibold | Monospaced | -0.24px | 1 |
| Stack tag | 8.5pt | Medium | Monospaced | normal | 1 |
| Feature title | 10pt | Semibold | Monospaced | -0.24px | 1 |
| Feature detail | 10pt | Regular | Monospaced | normal | 1 |
| Button label | 13–16pt | Medium | Sans-serif | normal | 1 |
| Badge title | 10pt | Medium | Monospaced | -0.24px | 1 |
| Nav link | 16pt | Regular | Sans-serif | normal | 1 |

### Special treatments

- **Headlines use weight 400 (Regular)**, not Semibold or Bold. Factory.ai headlines are light and spacious.
- **Negative tracking on headlines**: -1.2px for 28–32pt display text, creating a tight, modern industrial feel.
- **Monospace labels use negative tracking**: -0.24px at 12px, matching Factory.ai technical labels.
- **Uppercase** is required for all monospace labels: badges, metric labels, button labels, feature titles, system codes.
- **Minimum scale factor** is mandatory on small-width labels to prevent truncation on compact devices.

---

## 4. Spacing & Layout

### Grid system

- The onboarding view is wrapped in `GeometryReader` and sized responsively.
- Horizontal padding: `min(max(width * 0.055, 20), 36)` — adaptive between 20pt and 36pt.
- Max content width: 680pt (centered).
- Factory.ai uses a 12-column grid with 16px gutters. Onboarding adapts this to a centered single-column layout with consistent horizontal margins.

### Spacing scale

| Token | Value | Usage |
|---|---|---|
| `xs` | 4pt | Internal row gaps, icon-text spacing |
| `sm` | 8pt | Tight internal padding |
| `md` | 12–16pt | Card internal padding, VStack spacing |
| `lg` | 20–24pt | Section spacing, dot-matrix spacing |
| `xl` | 32–36pt | Top/bottom safe-area padding |
| `2xl` | 64–80pt | Major section vertical padding (hero sections) |

### Layout rules

- **No scroll** — Every page must fit entirely within the viewport. Use `compactHeight` flag (`height < 760`) to reduce spacing and font sizes on smaller devices.
- **Visual card height** is computed dynamically: `max(compact ? 270 : 326, min(height * 0.43, 390))`.
- **Bottom section is persistent** — Pagination dots and CTA are pinned near the safe-area bottom. Content above them is sized to never push them off-screen.

---

## 4a. Responsive Scaling Guide

### Base design canvas

All measurements in this document are authored against a **base design canvas of 375 × 667 pt** (iPhone 6 / iPhone SE 1st gen logical resolution). This is the smallest portrait viewport the onboarding must support perfectly. Every dimension — font, spacing, card height, button height — is defined at this base and scaled up for larger devices using a single proportional multiplier.

> **Why 375 × 667?** It is the most constrained portrait canvas in the modern iPhone lineup. If the layout fits here without scroll, it will fit everywhere.

### Scaling formula

Use `GeometryReader` to compute a single `scale` multiplier per screen:

```swift
struct OnboardingContainer: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

    /// Base design canvas in points
    private let baseSize = CGSize(width: 375, height: 667)

    var body: some View {
        GeometryReader { proxy in
            let current = proxy.size
            let ratioX = current.width / baseSize.width
            let ratioY = current.height / baseSize.height
            let scale = min(ratioX, ratioY)
            let isCompactHeight = current.height < 760

            ContentView(scale: scale, isCompactHeight: isCompactHeight)
                .frame(width: current.width, height: current.height)
        }
        .ignoresSafeArea()
    }
}
```

| Variable | Meaning |
|---|---|
| `ratioX` | Horizontal scale relative to 375 pt |
| `ratioY` | Vertical scale relative to 667 pt |
| `scale` | `min(ratioX, ratioY)` — preserves aspect ratio, prevents overflow |
| `isCompactHeight` | `true` when screen height < 760 pt (iPhone SE 3, mini, compact split-view) |

> **Always use `min()`, never `max()`**. Using `max()` would cause content to overflow on one axis.

### Device breakpoint reference

| Device | Logical size | ratioX | ratioY | `scale` | `isCompactHeight` |
|---|---|---|---|---|---|
| iPhone SE (1st) | 375 × 667 | 1.000 | 1.000 | **1.000** | true |
| iPhone SE (3rd) | 375 × 667 | 1.000 | 1.000 | **1.000** | true |
| iPhone mini | 375 × 812 | 1.000 | 1.217 | **1.000** | false |
| iPhone 14 / 15 | 390 × 844 | 1.040 | 1.265 | **1.040** | false |
| iPhone 16 Pro | 402 × 874 | 1.072 | 1.310 | **1.072** | false |
| iPhone 16 Pro Max | 440 × 956 | 1.173 | 1.433 | **1.173** | false |
| iPad (portrait) | 768 × 1024 | 2.048 | 1.535 | **1.535** | false |
| iPad (landscape) | 1024 × 768 | 2.731 | 1.151 | **1.151** | false |
| iPad Pro 12.9" (landscape) | 1366 × 1024 | 3.643 | 1.535 | **1.535** | false |

> On iPad landscape, `ratioY` becomes the limiting factor, so `scale` drops. Content remains proportional but uses less of the available width. Center the content with a `maxWidth` container.

### Scaled dimension helpers

Apply `scale` using these helpers. Never hardcode scaled values.

```swift
extension CGFloat {
    func scaled(by scale: CGFloat) -> CGFloat { self * scale }
}

// Usage inside views that receive `scale`:
// .font(.system(size: 28.scaled(by: scale), weight: .regular))
// .padding(.horizontal, 20.scaled(by: scale))
// .frame(height: 48.scaled(by: scale))
```

For **font sizes**, use a **capped scale** to prevent oversized text on iPad:

```swift
func fontScale(_ base: CGFloat, screenScale: CGFloat) -> CGFloat {
    let capped = min(screenScale, 1.35) // cap at +35%
    return base * capped
}
```

| Element | Base size (375×667) | Scale mode | Cap |
|---|---|---|---|
| Headline | 28 pt | `fontScale` | 1.35× |
| Body | 14 pt | `fontScale` | 1.30× |
| Button label | 14 pt | `fontScale` | 1.30× |
| Badge title | 10 pt | `fontScale` | 1.30× |
| Metric label | 10 pt | `fontScale` | 1.30× |
| Page counter | 11 pt | `fontScale` | 1.30× |
| Brand label | 12 pt | `fontScale` | 1.25× |
| Stack tag | 8.5 pt | `fontScale` | 1.25× |

> Monospace labels at ≤10pt scale conservatively because they are already small and must remain crisp.

### Layout element scaling

| Element | Base value | Scale mode | Notes |
|---|---|---|---|
| Horizontal padding | 20 pt | direct `scale` | Max 36 pt after scaling |
| Top safe-area padding | 20 pt | direct `scale` | Add `proxy.safeAreaInsets.top` |
| Bottom safe-area padding | 16 pt | direct `scale` | Add `proxy.safeAreaInsets.bottom` |
| Top bar height | 44 pt | direct `scale` | Fixed proportion |
| Headline top spacing | 16 pt | direct `scale` | Reduced to 10 pt when `isCompactHeight` |
| Body top spacing | 12 pt | direct `scale` | Reduced to 8 pt when `isCompactHeight` |
| Card top spacing | 20 pt | direct `scale` | Reduced to 12 pt when `isCompactHeight` |
| Card internal padding | 14 pt | direct `scale` | |
| Feature card gap | 12 pt | direct `scale` | |
| Pagination-to-CTA spacing | 24 pt | direct `scale` | |
| Button height | 48 pt | direct `scale` | Min 44 pt (HIG), max 56 pt |
| Button horizontal padding | 20 pt | direct `scale` | |
| Pagination dot height | 6 pt | direct `scale` | |
| Active dot width | 28 pt | direct `scale` | |
| Skip button tap area | 44 pt | fixed | Accessibility minimum, not scaled |

### Card height scaling

The hero card is the most critical responsive element. Compute its height dynamically:

```swift
func cardHeight(screenHeight: CGFloat, scale: CGFloat, isCompact: Bool) -> CGFloat {
    let baseHeight: CGFloat = isCompact ? 270 : 326
    let scaledBase = baseHeight * scale
    let proportional = screenHeight * 0.43
    let maxHeight: CGFloat = 390 * scale
    return max(scaledBase, min(proportional, maxHeight))
}
```

| Condition | Calculation |
|---|---|
| Compact height (< 760 pt) | `max(270 * scale, min(height * 0.43, 390 * scale))` |
| Regular height (≥ 760 pt) | `max(326 * scale, min(height * 0.43, 390 * scale))` |
| iPad (max width enforced) | Same formula, but card `maxWidth` = 680 pt |

> The card must never exceed 43% of screen height. On iPhone SE this yields ~286 pt (43% of 667). On iPhone 16 Pro Max it yields ~410 pt, but capped at `390 * 1.173 = 457 pt` — however the `min(height * 0.43)` clause will keep it at ~410 pt.

### iPad adaptations

On iPad, the single-column layout becomes visually stretched if full-width. Apply these constraints:

```swift
struct iPadContentWidth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity) // centers horizontally
    }
}
```

| Adaptation | Rule |
|---|---|
| Max content width | 680 pt, centered |
| Card max width | 680 pt |
| Button max width | 680 pt |
| Horizontal padding | `min(max(width * 0.055, 20), 36)` — on iPad this hits 36 pt, but content is centered inside 680 pt container |
| Font scale cap | 1.35× to prevent oversized typography |
| Feature cards layout | Side-by-side `HStack` instead of `VStack` when width > 500 pt |

### Compact height overrides

When `isCompactHeight == true` (iPhone SE, split-view), reduce spacing aggressively:

| Token | Regular | Compact |
|---|---|---|
| Headline top spacing | 16 × scale | 10 × scale |
| Body top spacing | 12 × scale | 8 × scale |
| Card top spacing | 20 × scale | 12 × scale |
| Card height base | 326 × scale | 270 × scale |
| Bottom nav top spacing | 24 × scale | 16 × scale |
| Feature card internal padding | 12 × scale | 8 × scale |

### Dynamic Type support

The onboarding must respect the user's content size preference without breaking the "no scroll" rule.

```swift
@Environment(\.dynamicTypeSize) private var dynamicTypeSize

var typeScaleMultiplier: CGFloat {
    switch dynamicTypeSize {
    case .xSmall, .small, .medium: return 1.0
    case .large: return 1.05
    case .xLarge: return 1.10
    case .xxLarge: return 1.15
    case .xxxLarge: return 1.20
    case .accessibility1: return 1.25
    case .accessibility2: return 1.30
    case .accessibility3: return 1.35
    case .accessibility4: return 1.40
    case .accessibility5: return 1.45
    @unknown default: return 1.0
    }
}
```

Apply `typeScaleMultiplier` to font sizes **after** screen-scale. Use `minimumScaleFactor` as a fallback:

```swift
Text("Headline text")
    .font(.system(size: 28.scaled(by: scale) * typeScaleMultiplier, weight: .regular))
    .minimumScaleFactor(0.75)
```

> When Dynamic Type exceeds `.xxxLarge`, consider reducing headline to 2 lines max and truncating body at 2 lines to preserve the no-scroll guarantee.

### Complete scaling implementation template

```swift
struct ScaledOnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let baseSize = CGSize(width: 375, height: 667)

    var body: some View {
        GeometryReader { proxy in
            let current = proxy.size
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom

            let ratioX = current.width / baseSize.width
            let ratioY = current.height / baseSize.height
            let scale = min(ratioX, ratioY)
            let isCompactHeight = current.height < 760

            let palette = OpenSpaceOnboardingPalette.resolve(colorScheme)

            VStack(spacing: 0) {
                TopBar(scale: scale, palette: palette)
                    .frame(height: 44.scaled(by: scale))
                    .padding(.top, safeTop)

                ScrollViewDisabledContainer {
                    VStack(spacing: 0) {
                        EyebrowBadge(scale: scale, palette: palette)
                            .padding(.top, (isCompactHeight ? 10 : 16).scaled(by: scale))

                        HeadlineText(scale: scale, typeScale: typeScaleMultiplier)
                            .padding(.top, (isCompactHeight ? 8 : 12).scaled(by: scale))

                        BodyText(scale: scale, typeScale: typeScaleMultiplier)
                            .padding(.top, (isCompactHeight ? 8 : 12).scaled(by: scale))

                        HeroCard(
                            scale: scale,
                            isCompact: isCompactHeight,
                            cardHeight: cardHeight(
                                screenHeight: current.height,
                                scale: scale,
                                isCompact: isCompactHeight
                            ),
                            palette: palette
                        )
                        .padding(.top, (isCompactHeight ? 12 : 20).scaled(by: scale))

                        Spacer(minLength: 0)

                        PaginationDots(scale: scale, palette: palette)
                            .padding(.bottom, 24.scaled(by: scale))

                        BottomNavigation(scale: scale, palette: palette)
                            .frame(height: 48.scaled(by: scale))
                            .padding(.bottom, safeBottom + 8.scaled(by: scale))
                    }
                    .padding(.horizontal, min(max(current.width * 0.055, 20), 36))
                }
            }
            .frame(width: current.width, height: current.height)
            .background(palette.background)
        }
    }

    private func cardHeight(screenHeight: CGFloat, scale: CGFloat, isCompact: Bool) -> CGFloat {
        let base: CGFloat = isCompact ? 270 : 326
        let scaledBase = base * scale
        let proportional = screenHeight * 0.43
        let maxH = 390 * scale
        return max(scaledBase, min(proportional, maxH))
    }
}
```

### Scaling checklist

- [ ] Base canvas is 375 × 667 pt; all dimensions authored against this.
- [ ] `scale = min(ratioX, ratioY)` is used globally, never `max()`.
- [ ] Font sizes use `fontScale` with a 1.35× cap on iPad.
- [ ] Layout spacing uses direct `scale` multiplication.
- [ ] `isCompactHeight` reduces top/card/bottom spacing when height < 760 pt.
- [ ] Card height is computed with `max(base * scale, min(height * 0.43, 390 * scale))`.
- [ ] iPad enforces max content width of 680 pt and centers horizontally.
- [ ] Dynamic Type multiplier is applied after screen-scale.
- [ ] `minimumScaleFactor` is set on all text to prevent truncation.
- [ ] Safe area insets (`safeTop`, `safeBottom`) are added to frame calculations, not multiplied by `scale`.
- [ ] Button tap targets remain ≥ 44 pt regardless of scale.
- [ ] Feature cards use `HStack` side-by-side on iPad when width > 500 pt.
- [ ] "No scroll" is verified on: iPhone SE (375×667), iPhone mini (375×812), iPhone 16 Pro Max (440×956), iPad portrait (768×1024), iPad landscape (1024×768).

---

## 5. Component Style Guide

### FactoryBadge

- **Shape**: Capsule (`.continuous`)
- **Height**: Intrinsic (padding 10pt horizontal, 7pt vertical)
- **Fill**: `surface` at 50% dark / 50% light (very subtle)
- **Stroke**: `border`, 1pt
- **Contents**: Orange dot (5pt) + optional SF Symbol (10pt) + uppercase title (10pt monospace)
- **Foreground**: `textMuted` (not `textPrimary`)

> Factory.ai badges are understated. The text is muted, not bright.

> **Ported from**: shadcn/ui Badge (outline variant) + Dot Matrix opacity hierarchy for the orange status dot.

### FactoryCardChrome

- **Shape**: `RoundedRectangle(cornerRadius: 6, style: .continuous)`
- **Fill**: `backgroundSecondary` at 100% dark (`#101010`) / 100% light (`#eeeeee`)
- **Stroke**: `border`, 1pt (`#3d3a39` dark / `#d8d0c1` light)
- **Clip**: Yes, to keep inner content inside the rounded border
- **Usage**: Wraps the hero visual/interactive area on every onboarding page.

> Factory.ai cards use `rounded-md` (6px), not large radii. The effect is sharp and industrial.

> **Ported from**: shadcn/ui Card + Watermelon UI dark documentation shell card chrome.

### FactoryPrimaryButtonStyle

- **Shape**: `RoundedRectangle(cornerRadius: 4, style: .continuous)`
- **Height**: 48–52pt
- **Fill**: `primaryActionFill`
- **Text**: `primaryActionText`, 13–16pt medium sans-serif, uppercase or title case, tracking normal
- **Pressed**: Scale 0.985, fill opacity 90%
- **Animation**: Spring (response 0.22, damping 0.72)
- **Focus ring**: 2pt offset ring using `accent` at 40% opacity (shadcn/ui focus pattern)

> Factory.ai CTAs use `rounded-sm` (4px) and solid fills. No ghost/outline primary buttons.

> **Ported from**: shadcn/ui Button (default variant) + Factory.ai solid fill discipline.

### FactorySecondaryButtonStyle

- **Shape**: `RoundedRectangle(cornerRadius: 4, style: .continuous)`
- **Height**: 48–52pt
- **Fill**: `surface` at 40% default, 25% pressed
- **Text**: `textPrimary`, 13pt medium sans-serif
- **Stroke**: `border`, 1pt
- **Pressed**: Scale 0.985
- **Focus ring**: 2pt offset ring using `accent` at 40% opacity

> **Ported from**: shadcn/ui Button (outline variant).

### Skip button

- **Shape**: `RoundedRectangle(cornerRadius: 4, style: .continuous)`
- **Fill**: Transparent
- **Text**: "SKIP", 11pt medium sans-serif, `textSecondary`
- **No border, no background** — Factory.ai skip/ghost buttons are pure text.
- **Tap area**: Minimum 44pt frame padding for accessibility.

### Pagination dots

- **Shape**: Capsule (`.continuous`)
- **Active**: Width 28pt, height 6pt, fill `accent`
- **Inactive**: Width 6pt, height 6pt, fill `border`
- **Animation**: Spring (response 0.34, damping 0.76)
- **Placement**: Above the CTA button, inside `VStack(spacing: 24)`.
- **Tap area**: Each dot wrapped in invisible `Button` with 44pt min tap target.

> **Ported from**: Watermelon UI tab/pill indicator pattern + Factory.ai signal accent.

### Feature highlight row (mini card)

- **Shape**: `RoundedRectangle(cornerRadius: 6, style: .continuous)`
- **Fill**: `backgroundSecondary` at 100% (`#101010` dark / `#eee` light)
- **Stroke**: `border`, 1pt
- **Icon container**: 28pt rounded rect, fill `accent` at 12% (first) or transparent (second)
- **Icon**: 12pt semibold, `accent` (first) or `textSecondary` (second)
- **Text**: Title 10pt semibold monospace uppercase; detail 10pt regular monospace
- **Stagger**: 0.05s delay between first and second card on entrance.

> **Ported from**: Watermelon UI component card header pattern.

### Terminal header (inside hero card)

- **Shape**: `RoundedRectangle(cornerRadius: 4, style: .continuous)`
- **Fill**: `surface` at 50%
- **Stroke**: `border`, 1pt
- **Contents**: Three status dots (accent, muted, muted) + metric label (10pt bold monospace uppercase) + stack tags (8.5pt semibold monospace)
- **Dot status indicator**: Uses Dot Matrix opacity hierarchy — active dot at 95% white, mid at 45%, inactive at 12%.

> **Ported from**: Factory.ai terminal widget + Dot Matrix dot opacity system.

### Command pill (install / copy pattern)

- **Shape**: `RoundedRectangle(cornerRadius: 8, style: .continuous)`
- **Fill**: `surface` at 25%
- **Stroke**: `border` at 50% opacity, 1pt
- **Text**: Monospace, 13–14pt, `textMuted`
- **Copy button**: 40pt square, `RoundedRectangle(cornerRadius: 8)`, same fill/stroke as pill, SF Symbol `doc.on.doc` at 13pt
- **Interaction**: Copy button scales to 0.96 on press, spring (0.18, 0.78)

> **Ported from**: Componentry command pill + Watermelon UI search bar stroke pattern.

---

## 6. Animation & Motion

### Philosophy

Motion explains state. It is never decorative. All animations respect `accessibilityReduceMotion`.

### Page entrance pattern

When a new page appears:

1. `appeared` state resets to `false`.
2. After 70ms delay, `appeared` becomes `true` with spring animation (response 0.48, damping 0.82).
3. Hero card scales from 0.985 to 1 and fades in.
4. Feature highlight rows stagger in with 0.05s delay.
5. Terminal header dots animate opacity from 0 → 1 with 0.08s stagger (Dot Matrix pattern).

### Page transition

- **Insertion**: `.move(edge: .trailing).combined(with: .opacity)`
- **Removal**: `.move(edge: .leading).combined(with: .opacity)`
- Triggered by `.id(store.currentPageData.id)` on `FeaturePageView`.

### Micro-interactions

| Element | Trigger | Animation |
|---|---|---|
| Primary/secondary button | Press | Scale 0.985, spring (0.22, 0.72) |
| Pagination dot | Page change | Width spring (0.34, 0.76) |
| Pairing toggle | Tap | Shield icon swap + orb offset spring (0.46, 0.72) |
| Prompt chip | Selection | Instant fill swap (no animation to feel snappy) |
| Typing cursor | Page appear | Typewriter reveal, 16ms per character |
| Response lines | Page appear | Slide-in + fade, 0.34s easeOut, stagger 0.07s |
| Queue rows | Page appear | Slide-up + fade, spring (0.38, 0.8), stagger 0.055s |
| Reasoning dial | Slider drag | Circular trim spring (0.42, 0.74) |
| Reasoning bars | Page appear | Scale Y from bottom, spring (0.42, 0.8), stagger 0.035s |
| Reasoning preset | Tap | Fill + stroke swap, spring (0.36, 0.76) |
| Terminal dots | State change | Opacity wave, 0.08s stagger |
| Copy button | Press | Scale 0.96, spring (0.18, 0.78) |

### Hero card ambient effects (allowed only inside card boundaries)

These effects are permitted **only** within the `FactoryCardChrome` clip boundary. They must never bleed into the page background.

| Effect | Source | Implementation |
|---|---|---|
| Pixel grid background | Factory.ai + Dot Matrix | `Canvas` ellipse fills, 20–22pt spacing, 1.0–1.2pt dot size, opacity 0.06 dark / 0.04 light |
| Diagonal hatch pattern | Factory.ai | `Canvas` stroked diagonal lines, 10–12pt spacing, opacity 0.025 dark / 0.04 light |
| Magnet lines | Componentry | `Canvas` vertical line segments, pointer-reactive displacement (iOS: `DragGesture`), muted gray |
| Dither gradient overlay | Componentry | `Canvas` ordered dot pattern overlay on gradient fills, 3pt spacing, 1.2pt dot size |
| Signal glitch shader | Factory.ai | `ShaderLibrary.default.factorySignalGlitch`, `progress` 0→1, `intensity` 0.55–0.82. Degrades gracefully. |

### Motion restrictions

- **No infinite ambient loops** — No pulsing glow rings, orbiting particles, or continuous breathing effects outside the hero card clip boundary.
- **One-shot only** — All motion is entrance or interaction driven, then settles.
- **Reduce Motion** — When enabled, all entrance animations become instant (`appeared = true` immediately), and typing reveals instantly. Hero card effects disable entirely.

---

## 7. Effects & Overlays

### Layering order (bottom to top)

1. `background` solid fill (`#020202`)
2. `PixelGridBackground` — dot matrix texture (very subtle)
3. `DiagonalHatchPattern` — diagonal line texture (even more subtle)
4. `FactoryCardChrome` content (`#101010` + `#3d3a39` border)
5. Interactive elements (buttons, sliders, chips)
6. Text and icon overlays

### PixelGridBackground

- **Spacing**: 20–22pt
- **Dot size**: 1.0–1.2pt
- **Opacity**: 0.06 dark / 0.04 light (Factory.ai keeps this extremely subtle)
- **Color**: `textPrimary`
- **Rendering**: `Canvas` with ellipse fills
- **Hit testing**: Disabled

> Factory.ai does not have a visible dot grid. If this effect competes with content, reduce opacity further or remove it.

> **Ported from**: Factory.ai subtle texture + Dot Matrix dot rendering discipline.

### DiagonalHatchPattern

- **Spacing**: 10–12pt
- **Opacity**: 0.025 dark / 0.04 light (barely perceptible)
- **Color**: `textPrimary`
- **Rendering**: `Canvas` with stroked diagonal lines
- **Hit testing**: Disabled

> This should be a ghost texture. If it is visible in a screenshot, it is too strong.

### FactorySignalGlitch (shader)

- Applied to the hero card chrome as a `colorEffect` using `ShaderLibrary.default.factorySignalGlitch`.
- Parameters: `progress` (0 → 1 on entrance), `intensity` (page-specific, 0.55–0.82).
- **Usage**: Subtle chromatic / signal-distortion effect on the card surface. Only visible on supported devices; degrades gracefully to no effect where Metal shaders are unavailable.

### DitherGradient (hero card overlay)

- **Usage**: Applied as an overlay on reasoning dial and gradient blobs inside the hero card.
- **Pattern**: Ordered dot matrix, 3pt spacing, 1.2pt dot size, opacity 0.15–0.35 based on gradient brightness.
- **Rendering**: `Canvas` with `blendMode(.overlay)`.
- **Color**: `textPrimary` at variable opacity.

> **Ported from**: Componentry dither gradient effect. Only visible inside card clip boundary.

### MagnetLines (interactive hero only)

- **Usage**: Inside the encrypted pairing hero card, vertical line segments react to touch drag.
- **Layout**: 8–12 columns of 2pt-wide vertical segments, 4pt gap.
- **Color**: `textMuted` at 25% opacity.
- **Interaction**: Segment height and opacity increase based on distance to touch point, spring (0.38, 0.8).
- **Rendering**: `Canvas` with `DragGesture` state.

> **Ported from**: Componentry magnet lines. Only active during user interaction; settles to default state on release.

---

## 8. Screen / Flow Pattern

### Onboarding structure

There are exactly **4 pages**, each following the same layout skeleton but with a distinct interactive hero visual.

```
┌─────────────────────────────────────┐
│ [Logo]  OpenSpace / AI Assistance     │  ← topBar, height 44pt
│                    PG.01 / 04   SKIP│
├─────────────────────────────────────┤
│ ◊ Encrypted Pairing          SEC-01 │  ← eyebrow badge + system code
│                                     │
│ End-to-end encrypted pairing        │  ← headline (sans-serif, 28–32pt, w400)
│ and chats                           │
│                                     │
│ Pair trusted devices, keep local    │  ← body (sans-serif, 13–15pt)
│ workspace context private...        │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ● ● ○    E2E CHANNEL            │ │  ← terminalHeader (radius 4px)
│ │ SWIFTUI / SWIFTDATA / TCA / MODEL│ │
│ │                                 │ │
│ │ [ INTERACTIVE HERO VISUAL ]     │ │  ← visualBody (page-specific)
│ │                                 │ │
│ │ ┌─────┐  ┌─────┐                │ │  ← highlightFooter
│ │ │icon │  │icon │                │ │
│ │ │title│  │title│                │ │
│ │ └─────┘  └─────┘                │ │
│ └─────────────────────────────────┘ │  ← FactoryCardChrome, cornerRadius 6
│                                     │
│  ●━━●──○──○                         │  ← pagination dots (above button)
│                                     │
│ [ BACK ] [ CONTINUE / ENTER ]       │  ← bottomNavigation
└─────────────────────────────────────┘
```

### Per-page interactive visuals

| Page | Model | Visual | Effect sources |
|---|---|---|---|
| 1 | `.encryptedPairing` | Device pairing diagram (iPhone ↔ lock shield ↔ MacBook) with toggle button | Factory.ai terminal aesthetic + Componentry magnet lines |
| 2 | `.ideaStudio` | Prompt mode chips (ASK/WRITE/EXPLORE) + typewriter prompt + response lines | Factory.ai signal accents + shadcn/ui chip/toggle group |
| 3 | `.promptQueue` | Queue list (RUNNING/NEXT/QUEUED/READY) + ADD FOLLOW-UP button | Watermelon UI card list + Dot Matrix opacity wave |
| 4 | `.reasoningControl` | Circular dial + slider + FAST/BALANCED/DEEP presets + bar chart | Factory.ai industrial controls + Componentry dither gradient + shadcn/ui Slider |

---

## 9. Dark / Light Theme

### Approach

A single `OpenSpaceOnboardingPalette` struct resolves all colors based on `ColorScheme`. Views must never hardcode hex values. Always call `OpenSpaceOnboardingPalette.resolve(colorScheme)`.

### Theme rules

- **Dark** is the primary design target. Light mode is derived by inverting the value spectrum while keeping the accent hue consistent.
- **Dark background is nearly pure black** (`#020202`). This is the most important Factory.ai signature.
- **Dark secondary surface** is `#101010` — just barely lifted from the background.
- **Borders** in dark mode use warm gray (`#3d3a39`), not cool gray. This warmth is essential to the Factory.ai feel.
- **Surface opacity** is higher in light mode because white backgrounds need more contrast to show borders.
- **Pixel grid and hatch** opacities are extremely low in both modes. If they are visible in a screenshot, they are too strong.

### Testing requirement

Every new component or screen must be visually checked in both dark and light mode before merging.

---

## 10. Accessibility

### Contrast

- All text meets WCAG AA against its background.
- `textMuted` is the lowest-contrast text token; it is only used for metadata/hints, never for primary reading.

### Motion

- `@Environment(\.accessibilityReduceMotion)` is checked before running any entrance animation or typewriter effect.
- When reduced motion is enabled, all state changes are instant.
- Hero card Canvas effects (magnet lines, dither, pixel grid) disable entirely when reduced motion is on.

### Touch targets

- Primary/secondary buttons: 48–52pt height, full-width within padding.
- Skip button: Pure text tap area (ensure frame padding ≥ 44pt).
- Pagination dots: 6pt height, but wrapped in a `Button` with invisible padding to enlarge the tap area.
- Slider (reasoning): Native `Slider` with `.tint(accent)`.
- Chip buttons: Minimum 44pt height, 80pt width.

### Labels

- Every interactive element has an `accessibilityLabel`.
- The logo block combines its children into a single label: "OpenSpace AI assistance".
- The reasoning slider reports its current percentage value via `accessibilityValue`.
- Terminal header dots report status: "E2E channel active, two of three connections secure."

---

## 11. Asset Guidelines

### Icons

- All icons are **SF Symbols**.
- Preferred weights: `.semibold` for small (9–12pt), `.medium` for large (30–32pt).
- Icon colors follow the token system: `accent`, `textPrimary`, `textSecondary`, `textMuted`, `warning`, `success`.

### Illustrations

- No raster illustrations are used. All visuals are composed from SwiftUI primitives:
  - `RoundedRectangle`, `Circle`, `Capsule`
  - `Canvas` for grid, hatch, dither, and magnet line patterns
  - `LinearGradient` for response-line shimmer
  - `ShaderLibrary` for glitch effect

### Logo mark

- A 20pt rounded-rect container with a 7×14pt orange offset rectangle inside.
- This is drawn in code; no image asset required.

---

## 12. Reference Component Mapping

This table maps shadcn/ui primitives to SwiftUI implementations for this design system.

| shadcn/ui Primitive | SwiftUI Implementation | Notes |
|---|---|---|
| Button (default) | `FactoryPrimaryButtonStyle` | Solid fill, 4px radius, spring press |
| Button (outline) | `FactorySecondaryButtonStyle` | Transparent fill, 1pt border, spring press |
| Button (ghost) | Skip button | Pure text, no chrome |
| Card | `FactoryCardChrome` | 6px radius, `#101010` fill, warm border |
| Badge (outline) | `FactoryBadge` | Capsule, muted text, orange dot |
| Tabs | Pagination dots + page transitions | Capsule indicators, spring width |
| Slider | Native `Slider` | `.tint(accent)`, custom track height optional |
| Switch | Custom toggle with shield icon | Factory.ai industrial toggle |
| Chip / Toggle Group | Prompt mode chips | Instant fill swap, no animation |
| Command / KBD | Terminal header + command pill | Monospace, dark fill, copy button |
| Separator | `Divider` with `border` color | 1pt, warm gray |
| Skeleton | Dot Matrix opacity wave | For queue loading states |

---

## 13. Implementation Checklist

Before merging any onboarding change or new screen:

- [ ] All colors use `OpenSpaceOnboardingPalette` tokens, never hardcoded hex.
- [ ] Dark background is `#020202`, not a softened gray like `#050505` or `#0a0a0a`.
- [ ] Both dark and light mode have been verified in Simulator.
- [ ] No vertical scroll is required; content fits the viewport on iPhone 17 Pro and compact devices.
- [ ] Headlines use **sans-serif weight 400** with negative tracking, not bold/monospace.
- [ ] Monospace is reserved for small technical labels (≤12pt) only.
- [ ] All uppercase labels (badges, metrics, feature titles) are uppercase.
- [ ] Border radius follows the scale: **4px** buttons/badges, **6px** cards, **10px** large containers.
- [ ] Cards use `#101010` fill + `#3d3a39` border in dark mode (warm gray, not cool gray).
- [ ] All animations respect `accessibilityReduceMotion`.
- [ ] All interactive elements have `accessibilityLabel`.
- [ ] Primary CTA uses `FactoryPrimaryButtonStyle`; secondary uses `FactorySecondaryButtonStyle`.
- [ ] Pagination dots are placed **above** the CTA with 24pt spacing.
- [ ] Feature highlight cards use `FactoryCardChrome` with 6px corner radius.
- [ ] Background texture layers are nearly invisible. If visible in screenshots, reduce opacity.
- [ ] `minimumScaleFactor` is set on every small label to prevent truncation.
- [ ] Hero card Canvas effects (magnet lines, dither, pixel grid) are clipped to card boundary.
- [ ] No infinite ambient loops exist outside hero card clip boundary.
- [ ] Base canvas is 375 × 667 pt; all dimensions authored against this.
- [ ] `scale = min(ratioX, ratioY)` is used globally, never `max()`.
- [ ] Font sizes use `fontScale` with a 1.35× cap on iPad.
- [ ] `isCompactHeight` reduces spacing when height < 760 pt.
- [ ] Card height uses `max(base * scale, min(height * 0.43, 390 * scale))`.
- [ ] iPad enforces max content width of 680 pt and centers horizontally.
- [ ] Dynamic Type multiplier is applied after screen-scale.
- [ ] Safe area insets are added, not multiplied by `scale`.
- [ ] "No scroll" verified on iPhone SE, iPhone 16 Pro Max, iPad portrait, iPad landscape.
- [ ] Build passes with zero SwiftFormat errors.
