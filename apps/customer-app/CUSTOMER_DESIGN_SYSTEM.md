# Kisan Setu — Customer Design System

> Extracted directly from `customer_side/stitch_kisan_setu_mobile_app/kisan_setu/DESIGN.md` and verified against `code.html` Tailwind tokens.

## 1. Color Palette (Material 3 Tokens)

| Token Name | Hex | Usage |
|---|---|---|
| `primary` | `#005128` | Primary brand color, active tabs, splash background, primary headers |
| `onPrimary` | `#FFFFFF` | Text & icons on `primary` |
| `primaryContainer` | `#146B3A` | Primary CTA buttons, elevated brand containers |
| `onPrimaryContainer` | `#97E9AB` | Subtle text/icons on `primaryContainer` |
| `primaryFixed` | `#A2F5B6` | Highlighted chips, positive status fills |
| `primaryFixedDim` | `#87D89C` | Secondary accents |
| `onPrimaryFixed` | `#00210D` | High-contrast text on `primaryFixed` |
| `secondary` | `#006D36` | Active indicators, verified badges, secondary CTAs |
| `secondaryContainer` | `#8FF9AA` | "Free Delivery Unlocked" banners, verified tags |
| `onSecondaryContainer` | `#00743A` | Text/icons inside `secondaryContainer` |
| `tertiary` | `#584200` | Harvest gold text/icons on light surfaces |
| `tertiaryContainer` | `#755900` | Warm accent container |
| `tertiaryFixed` | `#FFDF95` | Seasonal badges, warm pills |
| `tertiaryFixedDim` | `#F4BF1B` | Cart badge, "Plan Ahead" pill, star ratings |
| `harvestGold` | `#FFC928` | Banner CTA buttons ("Shop Now"), ratings, deal highlights |
| `onTertiaryFixed` | `#251A00` | Dark text on Harvest Gold / `tertiaryFixed` |
| `surface` / `background` | `#F2FCF2` | Main scaffold background |
| `surfaceContainerLowest` | `#FFFFFF` | Product cards, forms, elevated containers |
| `surfaceContainerLow` | `#ECF6EC` | Input fills, subtle nested cards, location pill |
| `surfaceContainer` | `#E6F1E7` | Icon circles, tonal cards |
| `surfaceContainerHigh` | `#E1EBE1` | Secondary containers |
| `surfaceContainerHighest` | `#DBE5DB` | Progress tracks, dividers, skeleton placeholders |
| `onSurface` | `#151E18` | Primary headings & body text |
| `onSurfaceVariant` | `#3F4940` | Secondary labels, subtitles |
| `outline` | `#6F7A70` | Placeholders, muted icons, borders |
| `outlineVariant` | `#BFC9BE` | Subtle 1px card borders & dividers |
| `error` | `#BA1A1A` | Error states, out-of-stock, cancellation |
| `errorContainer` | `#FFDAD6` | Error banner backgrounds |
| `onErrorContainer` | `#93000A` | Text/icons inside `errorContainer` |

## 2. Typography (`Inter`)

| Role | Size | Line Height | Weight | Letter Spacing |
|---|---|---|---|---|
| `displayLarge` | 36px | 44px | `w700` (Bold) | -0.02em |
| `headlineLarge` (`displayLgMobile`) | 28px | 36px | `w700` (Bold) | -0.01em |
| `headlineMedium` | 22px | 28px | `w600` (SemiBold) | 0em |
| `headlineSmall` | 18px | 24px | `w600` (SemiBold) | 0em |
| `bodyLarge` | 16px | 24px | `w400` (Regular) | 0.01em |
| `bodyMedium` | 14px | 20px | `w400` (Regular) | 0.015em |
| `bodySmall` | 12px | 16px | `w400` (Regular) | 0.02em |
| `labelLarge` | 14px | 20px | `w600` (SemiBold) | 0.01em |
| `labelMedium` | 12px | 16px | `w600` (SemiBold) | 0.04em |
| `labelSmall` | 11px | 14px | `w600` (SemiBold) | 0.05em |

## 3. Spacing & Grid (8dp Spatial System)
- `spaceXs`: `4.0`
- `spaceSm`: `8.0`
- `gutterMobile`: `12.0`
- `spaceMd` / `marginMobile`: `16.0`
- `spaceLg` / `marginTablet`: `24.0`
- `spaceXl`: `32.0`
- Minimum interactive touch target: **48×48dp** (44×44dp minimum for compact header icon buttons).

## 4. Border Radius
- `radiusSm`: `4.0` (`0.25rem`)
- `radiusMd` (Inputs, buttons, filter chips): `8.0` (`0.5rem`)
- `radiusLg` (Cards, banners, search bar): `12.0` (`0.75rem`)
- `radiusXl` (Feature cards, bottom sheets top corners): `16.0`–`24.0`
- `radiusFull`: `9999.0` (Status pills, badges, avatars)

## 5. Elevation & Shadows
- **Level 0**: Flat on `#F2FCF2` canvas, 0 shadow.
- **Level 1 (Cards)**: `#FFFFFF` with `0px 2px 6px rgba(20, 40, 25, 0.04)` and optional `1px` `#E5ECE6`/`#BFC9BE` border.
- **Level 2 (Sticky Headers / Sheets)**: `0px 4px 12px rgba(20, 40, 25, 0.08)`.
- **Level 3 (Floating Cart / Modals)**: `0px 8px 24px rgba(20, 40, 25, 0.12)`.
