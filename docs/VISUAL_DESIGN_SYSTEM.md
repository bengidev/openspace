# OpenSpace — Visual Design Specification
## Designer-to-Developer Guidelines

---

## 1. Vision & Philosophy

**Design Direction: Retro-Futuristic Terminal UI / Cyberpunk Minimalist**

OpenSpace is an AI workspace app that adopts a classic computer terminal aesthetic. Imagine working in front of a black CRT monitor with phosphor-white text — clean, technical, free from color distractions.

### Design Principles
1. **Monochrome First** — No colors other than grayscale. Accents are only white (dark mode) or black (light mode).
2. **Terminal Authenticity** — Use terminal elements: prompt `>>>`, block cursor, typing effect, command-line hierarchy.
3. **CRT Authenticity** — Subtle scanlines, edge vignette, noise texture, phosphor glow.
4. **Motion as Feedback** — Every element enters with a story. No element should appear without animation.
5. **One Screen, No Scroll** — All onboarding content must fit within a single viewport without scrolling.

### Visual References
- **Componentry.fun** — Monospaced typography, magnetic dock, glitch effects
- **DotMatrix** — CRT loaders, neon drift, pulse ladder, glyph pulse
- **Watermelon UI** — Cyberpunk minimalism, high contrast, dark theme

---

## 2. Color Palette

### Color Philosophy
Colors are restricted to grayscale to maintain focus on content. No blue, green, red, or any other colored hues except for critical status indicators (e.g., error states).

### Color Tokens

| Token | Dark Mode | Light Mode | Usage |
|-------|-----------|------------|-------|
| Background | `#0A0A0A` | `#FAFAFA` | Root background |
| Background Elevated | `#141414` | `#F0F0F0` | Cards, panels, elevated surfaces |
| Text Primary | `#F5F5F5` | `#111111` | Headlines, body, CTA text |
| Text Dim | `#888888` | `#666666` | Subtitles, captions, secondary info |
| Text Faint | `#444444` | `#AAAAAA` | Labels, hints, metadata |
| Accent | `#FFFFFF` | `#000000` | Primary buttons, active states, highlights |
| Accent Inverse | `#000000` | `#FFFFFF` | Text on accent background |
| Border | `#2A2A2A` | `#DDDDDD` | Card borders, dividers |
| Divider | `#333333` | `#CCCCCC` | Horizontal rules |
| Grid Line | `#1F1F1F` | `#E5E5E5` | Background grid pattern |

### CRT Overlay Colors

| Effect | Dark Mode | Light Mode | Usage |
|--------|-----------|------------|-------|
| Scanline | Black 40% opacity | Black 6% opacity | Horizontal scanlines overlay |
| Vignette | Black 50% opacity | Black 10% opacity | Edge darkening |
| Noise | White 4% opacity | Black 3% opacity | CRT grain texture |

### Color Rules
- Always use color tokens. Never hardcode hex values in view code.
- All colors must be adaptive to dark/light mode — no fixed colors.
- Opacity adjustments must be relative to the base color token.

---

## 3. Typography

### Typeface
- **Primary**: System Monospace (SF Mono / iOS system monospaced)
- **Fallback**: Courier / Menlo for other platforms
- **Usage**: All UI text must be monospace — no exceptions for body, headline, or caption.

### Type Scale

| Level | Size | Weight | Usage |
|-------|------|--------|-------|
| Display | 30pt | Bold | Hero headlines (e.g., "Welcome") |
| H1 | 22pt | Bold | Card headlines, page titles |
| H2 | 20pt | Bold | Section titles |
| Body | 14pt | Regular | Descriptions, explanations |
| Caption | 13pt | Regular | Secondary text, hints |
| Label | 11pt | Medium | Metadata, tags, labels |
| Micro | 10pt | Bold | Badges, status indicators |
| Nano | 9pt | Medium | File extensions, micro labels |

### Special Treatments
- **Tracking**: Header section labels use 2pt letter-spacing for a technical/military feel.
- **Line Spacing**: Body text uses 1.4× line-height (approx. 4pt extra) for readability.
- **Scaling**: Headlines may scale down to a minimum of 90% for adaptive layout.
- **Glitch Text**: Brand headline ("OPENSPACE") uses a glitch effect — 3 text layers with monochrome ghost offsets.

---

## 4. Spacing & Layout

### Grid System
- **Base unit**: 4pt
- **Background grid**: Subtle grid with 40pt spacing, 40% opacity — used as texture, not layout structure.
- **Screen padding**: 20pt horizontal (leading/trailing), 24pt vertical (top/bottom).

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| XS | 4pt | Tight gaps, icon padding |
| SM | 8pt | Default element gap |
| MD | 16pt | Section internal spacing |
| LG | 24pt | Section-to-section gap |
| XL | 32pt | Major section breaks |
| XXL | 48pt | Hero-to-content spacing |

### Layout Rules
- All onboarding content must fit within one viewport — no scrolling.
- Elements are arranged vertically using VStack. No complex multi-column layout.
- Card width follows screen width minus 40pt padding (20pt each side).

---

## 5. Component Style Guide

### 5.1 Button (Primary CTA)

**Labels**: Continue / Get Started / Done

| State | Background | Text | Border |
|-------|------------|------|--------|
| Default | Accent (white/black) | Accent Inverse | None |
| Pressed | Same | Same | Glow intensify |
| Hover (macOS) | Same | Same | Subtle glow |

- **Shape**: Rectangle with 6pt corner radius (not pill-shaped)
- **Height**: 48pt minimum
- **Typography**: Body size, medium weight, 1pt tracking
- **Interaction**: Scale down to 0.96 on press, spring animation

### 5.2 Badge / Tag

**Format**: `[ BETA ]` — brackets with spaces inside.

- **Background**: Transparent or Background Elevated
- **Border**: 1pt Border color
- **Typography**: Micro size (10pt), bold
- **Usage**: Status labels, version tags, feature indicators

### 5.3 Status Indicator

**Format**: `● ONLINE` or `● ACTIVE`

- **Dot**: 6pt circle, Accent color, with subtle pulse animation
- **Text**: Label size (11pt), medium weight
- **Usage**: Connection status, system state

### 5.4 Divider

**Format**: `——— * ———` — horizontal line with centered asterisk.

- **Color**: Divider token
- **Thickness**: 1pt
- **Usage**: Section separator

### 5.5 Card

- **Background**: Background Elevated
- **Border**: 1pt Border color
- **Corner Radius**: 8pt
- **Padding**: 20pt internal
- **Shadow**: None — all depth is built from border and background contrast

---

## 6. Animation & Motion

### 6.1 Motion Philosophy
Motion is not decoration — motion is feedback. Every element that appears must have an entrance story. No element should appear abruptly without animation.

### 6.2 Entrance Animation Pattern
All elements enter with a combination of:
- **Opacity**: 0 → 1
- **Offset Y**: +8pt → 0
- **Scale**: 0.9 → 1.0
- **Easing**: Spring (response 0.4s, damping 0.75)

### 6.3 Stagger Delay
For lists or groups of elements, use incremental delays:
- **Default stagger**: 0.08s between items
- **Feature badges**: 0.08s
- **Checklist items**: 0.1s
- **Chat bubbles**: 0.12s
- **File grid items**: 0.06s

### 6.4 Page Transition
- **Direction**: Horizontal slide (trailing → leading)
- **Easing**: Asymmetric — insertion moves from trailing + opacity, removal moves to leading + opacity

### 6.5 Micro-Interactions

| Element | Trigger | Animation |
|---------|---------|-----------|
| Primary Button | Press | Scale 0.96 + glow intensify |
| Primary Button | Hover (macOS) | Subtle glow 0.5 intensity |
| Checkmark | Appear | Scale 0→1 with spring |
| Chat bubble | Appear | Slide up 12pt + opacity + stagger 0.12s |
| File item | Appear | Slide up 10pt + opacity + stagger 0.06s |
| Feature badge | Appear | Scale 0.8→1 + stagger 0.08s |
| Pagination dot | Active change | Spring scale + width morph |

### 6.6 Continuous Animations
- **Terminal Prompt**: `>>>` appears one by one, typing 0.12s per character, pause, delete, loop.
- **Terminal Cursor**: Blinking block, toggle opacity every 0.53s.
- **Glitch Text**: Auto-trigger every 0.5–1.5 seconds, ghost layers opacity pulse.

### 6.7 Animation Restrictions
- **No** infinite pulse/glow rings (continuously pulsing circles).
- **No** orbiting elements.
- **No** animated gradient backgrounds.
- All continuous animations must be subtle and must not interfere with readability.

---

## 7. CRT Effects

### Layering Order (bottom to top)
1. Background grid
2. Content
3. Scanlines overlay
4. Vignette overlay
5. Noise overlay (optional)

### Scanlines
- **Direction**: Horizontal
- **Density**: ~120 lines per screen height
- **Opacity**: 18% (dark), 6% (light)
- **Color**: Black

### Vignette
- **Shape**: Radial gradient, dark at edges
- **Opacity**: 50% (dark), 10% (light)
- **Purpose**: Simulate CRT edge darkening

### Noise
- **Pattern**: Random pixel grain
- **Opacity**: 4% (dark), 3% (light)
- **Purpose**: Analog texture

### Flicker
- **Trigger**: Random interval 3–8 seconds
- **Effect**: Subtle brightness shift
- **Intensity**: Very subtle — must not be distracting

---

## 8. Onboarding Pattern (4 Pages)

### Layout Structure per Page
```
[Header Row]
  >>> OPENSPACE                ● ONLINE   v1.0.0

[Hero Section]
  Large Icon / Visual
  Headline (H1)
  Subtitle (Body)

[Divider]
  ——— * ———

[Section Label]
  GETTING STARTED              01/04

[Content Card]
  Rich content per page (badges, chat bubbles, file grid, checklist)

[Action Area]
  Pagination Dots (above button)
  [Continue Button]
```

### Page Content Types

| Page | Name | Main Visual |
|------|------|-------------|
| 1 | Welcome | Large icon + staggered feature badges |
| 2 | Chat | Chat bubble mockups |
| 3 | Organize | File grid mockup |
| 4 | Ready | Checklist items with checkmark animation |

### Pagination Dots
- **Position**: Above the Continue button
- **Spacing**: 24pt from button
- **Active**: Pill shape (20pt wide × 8pt tall), Accent color
- **Inactive**: Circle (8pt), Border color
- **Animation**: Spring morphing on page change

---

## 9. Dark / Light Theme

### Approach
All colors use tokens that automatically swap based on the system color scheme. No manual toggle inside the app.

### Rules
1. Test every screen in both modes before release.
2. CRT overlays are more visible in dark mode, more subtle in light mode.
3. Text contrast must be minimum 4.5:1 in both modes.
4. Borders must be visible enough in both modes to define card edges.

---

## 10. Accessibility

### Contrast
- All text must meet WCAG AA (minimum 4.5:1 contrast ratio).
- Text Faint is only for decorative/hint purposes, never for important information.

### Motion
- Support Reduce Motion: disable glitch effects, use simple fades.
- All entrance animations must be under 1 second.

### Touch Targets
- Minimum touch target: 44pt × 44pt.
- Continue button: 48pt height, full width minus padding.

---

## 11. Asset Guidelines

### Icons
- Use SF Symbols with .medium or .semibold weight.
- All icons are monochrome — no colored icons.
- Large onboarding icons: container size 80–100pt.

### Illustrations
- No complex vector illustrations.
- Visuals are built from UI components (grid, badges, bubbles, file items).

---

## 12. Implementation Checklist

Before merging any new feature:

- [ ] All text uses monospace font
- [ ] All colors use tokens (no hardcoded hex)
- [ ] Every element has entrance animation (opacity + offset + scale)
- [ ] List items use stagger delay
- [ ] Content fits within one screen without scrolling
- [ ] Visual tested in dark and light mode
- [ ] Interactive elements have micro-interaction
- [ ] Primary button uses TerminalButton style
- [ ] Brand headline uses GlitchText
- [ ] No infinite glow/pulse animation
- [ ] Text contrast meets WCAG AA

---

*This document is a living specification — update as the design evolves.*
