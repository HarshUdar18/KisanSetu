---
name: Kisan Setu
colors:
  surface: '#f2fcf2'
  surface-dim: '#d2ddd3'
  surface-bright: '#f2fcf2'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ecf6ec'
  surface-container: '#e6f1e7'
  surface-container-high: '#e1ebe1'
  surface-container-highest: '#dbe5db'
  on-surface: '#151e18'
  on-surface-variant: '#3f4940'
  inverse-surface: '#29332c'
  inverse-on-surface: '#e9f3e9'
  outline: '#6f7a70'
  outline-variant: '#bfc9be'
  surface-tint: '#166c3b'
  primary: '#005128'
  on-primary: '#ffffff'
  primary-container: '#146b3a'
  on-primary-container: '#97e9ab'
  inverse-primary: '#87d89c'
  secondary: '#006d36'
  on-secondary: '#ffffff'
  secondary-container: '#8ff9aa'
  on-secondary-container: '#00743a'
  tertiary: '#584200'
  on-tertiary: '#ffffff'
  tertiary-container: '#755900'
  on-tertiary-container: '#ffd158'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a2f5b6'
  primary-fixed-dim: '#87d89c'
  on-primary-fixed: '#00210d'
  on-primary-fixed-variant: '#005229'
  secondary-fixed: '#8ff9aa'
  secondary-fixed-dim: '#73dc90'
  on-secondary-fixed: '#00210c'
  on-secondary-fixed-variant: '#005227'
  tertiary-fixed: '#ffdf95'
  tertiary-fixed-dim: '#f4bf1b'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#f2fcf2'
  on-background: '#151e18'
  surface-variant: '#dbe5db'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.015em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-mobile: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a high-trust, frictionless bridge connecting agricultural producers, Farmer Producer Organisations (FPOs), and everyday household consumers. Rooted in Material 3 principles and tailored for high-contrast usability across diverse environments—from high-glare farm fields to dim indoor kitchens—the visual language balances institutional reliability with agrarian warmth.

The aesthetic blends **Corporate / Modern** utilitarian precision with rich tactile clarity. Interfaces prioritize intuitive wayfinding, generous touch targets (minimum 48×48dp), clear produce grading badges, transparent unit pricing, and prominent fulfillment tracking. Visual elements remain dependable, transparent, and direct, deliberately steering away from decorative abstractions to ensure immediate legibility for both digitally seasoned urban buyers and rural producer networks.

## Colors

The palette is anchored in an authoritative deep field green (`#146B3A`) representing growth, institutional security, and agricultural stability. The secondary green (`#2E9B57`) injects fresh energy for active indicators, secondary actions, and verified states. A harvest gold accent (`#FFC928`) highlights premium harvest batches, seasonal recommendations, ratings, and deal banners without evoking artificial urgency.

Backgrounds utilize a cool, desaturated off-white tinted with sage (`#F7F9F6`) to prevent screen glare during outdoor use, allowing crisp white cards (`#FFFFFF`) to clearly demarcate distinct inventory units. Typography relies on deep carbon green (`#202820`) for optimal contrast against light backgrounds, while muted stone green (`#6B756D`) provides clear visual hierarchy for secondary attributes, quantity increments, and logistics metadata. Semantic states feature an earthy brick red (`#D94141`) for errors or stock depletions, alongside a crisp harvest green (`#25834A`) for successful transactions and quality certifications.

## Typography

Inter serves as the unified typographic engine across all levels, chosen for its neutral clarity, robust x-height, and superior legibility on high-density mobile screens under variable lighting.

Headline weights use semi-bold (`600`) and bold (`700`) to anchor category divisions, farmer identities, and batch price tiers. Body text maintains comfortable reading rhythm through generous line-heights, ensuring multi-line produce descriptions and nutritional provenance notes avoid visual crowding. Labels utilize slight tracking expansion (`0.01em` to `0.05em`) in compact sizes (`11px` to `14px`) to preserve clarity inside metadata chips, produce weight tags, and status ribbons.

## Layout & Spacing

The layout is built upon an 8dp/8pt spatial grid, systematically maintaining visual cohesion and predictable touch rhythm across Android viewport variations.

- **Mobile (< 600dp):** Employs a 4-column responsive grid with a strict 16dp outer screen margin and 12dp column gutters. Product listings utilize a 2-column card architecture or single-column detail rows with 8dp inner item gaps.
- **Tablet / Large Mobile (600dp - 840dp):** Expands to an 8-column grid with 24dp margins and 16dp gutters. Category navigation switches to an adaptive horizontal shelf or side navigation rail.
- **Vertical Spacing Rhythm:** Component stacks conform to the `space-*` scale: 4dp (`space-xs`) between badge icons and textual labels, 8dp (`space-sm`) between title and price lines, 16dp (`space-md`) between grouped card items, 24dp (`space-lg`) between major screen sections, and 32dp (`space-xl`) separating floating action zones or primary cart summaries.

## Elevation & Depth

Visual hierarchy uses Material 3 tonal layering combined with subtle ambient shadows tinted with dark foliage tones rather than harsh achromatic black. This keeps the agricultural interface feeling soft, earthy, and unified.

- **Level 0 (Flat / Canvas):** Applied to the main background (`#F7F9F6`). Zero shadow. Structural boundaries rely on soft border fills (`#E5ECE6`) or color field separation.
- **Level 1 (Cards & Feed Surfaces):** Resting produce cards, FPO profiles, and list modules use a pure white surface (`#FFFFFF`) framed by a subtle 1px border (`#E5ECE6`) and an ambient shadow: `0px 2px 6px rgba(20, 40, 25, 0.04)`.
- **Level 2 (Sticky Headers & Sheets):** Top application bars, filtering bottom sheets, and sticky category tabs cast a broader soft shadow: `0px 4px 12px rgba(20, 40, 25, 0.08)`.
- **Level 3 (Floating Actions & Modals):** Floating cart triggers, batch quantity counters, and checkout modals elevate with `0px 8px 24px rgba(20, 40, 25, 0.12)`, drawing immediate focus while maintaining soft organic diffusion.

## Shapes

The design system standardizes on a Level 2 (`0.5rem` / `8px` base) roundedness profile, balancing modern consumer software polish with structured industrial durability.

- **Interactive Elements & Micro-Surfaces:** Form inputs, action buttons, quantity toggles, and metadata tags use `8px` (`0.5rem`) corner radiuses for crisp containment.
- **Container Surfaces:** Product showcase cards, farmer profile containers, and order detail groups use `rounded-lg` (`16px` / `1rem`) corner radiuses, reflecting the natural softness of organic produce while preserving rigid grid alignment.
- **Persistent Bottom Sheets & Drawers:** Modal sheets and sliding batch detail trays apply `rounded-xl` (`24px` / `1.5rem`) specifically to the top-left and top-right apexes.
- **Badges & Small Status Chips:** Pure pill profiles (`9999px`) are reserved exclusively for verification status tags, organic certification markers, and discount pills.

## Components

### Buttons
- **Primary Action:** Solid background (`#146B3A`) with white text (`#FFFFFF`), `8px` border radius, minimum height of `48dp`, and horizontal padding of `20dp`. Active states step down to `#0F522C`.
- **Secondary / Add to Cart:** Background tint (`#EAF5EC`) with primary green text (`#146B3A`) and a subtle 1px border (`#2E9B57`). When selected, smoothly transitions into an inline segmented quantity stepper.
- **Tertiary / Ghost:** Text-only in `#146B3A` with a 48dp target bounding box, used for secondary actions like "View Farm Certifications" or "Price Breakdown".

### Chips & Badges
- **Produce Badges:** Pill-shaped tags featuring harvest origin (e.g., "Nashik Cluster"), harvest date, and grade. Background is `#EAF5EC` with `#146B3A` text for standard lots; `#FFF8E1` with `#8C6500` text for Grade-A/Organic batches.
- **Filter Chips:** 36dp tall, `8px` radius. Inactive: `#FFFFFF` fill with 1px `#D3DDD5` stroke and `#202820` label. Selected: `#146B3A` fill with `#FFFFFF` label and leading check icon.

### Cards
- **Product Card:** Elevated surface (`#FFFFFF`), `16px` corner radius, 1px border (`#E5ECE6`). Contains a 1:1 produce preview image with a subtle inset tag for harvest freshness (e.g., "Harvested 8 hrs ago"), followed by the local/FPO name in `body-sm` (`#6B756D`), product title in `headline-sm`, unit price prominently scaled in bold, and a fixed 48dp add/increment action.
- **Farmer / FPO Identity Card:** Features the producer's photo/logo, verified collective badge, distance radius in kilometers, and active crop yields.

### Inputs & Selection Controls
- **Text & Search Inputs:** Outlined style with `8px` radius, 52dp height, `#FFFFFF` fill, and `#6B756D` border. Focus activates a 2px `#146B3A` stroke with zero blur glow. Search fields include a leading microphone input shortcut for vernacular voice search.
- **Checkboxes & Radios:** 24×24dp touch boundary. Selected states utilize `#146B3A` fill with crisp white internal glyphs. Unselected states use a 2px border in `#6B756D`.

### Lists & Activity Rows
- **Order & Inventory Tracking:** 72dp minimum row height, separated by 1px divider lines (`#F0F4F1`). Left side anchors thumbnail or date marker; center displays crop identity and weight; right side retains bold order status chips (`#25834A` for "Dispatched", `#FFC928` for "Packaging").