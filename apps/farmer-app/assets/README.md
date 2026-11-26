# Kisan Setu — Centralized Assets & Image Management

This directory is the single source of truth for all static visual assets shared across the Kisan Setu platform (Customer App, Farmer App, Delivery App, and React Admin Panel).

## Folder Structure

```text
assets/
├── branding/
│   ├── logo/               # Primary, white, dark, icon, and favicon variants
│   ├── splash/             # Splash screen assets
│   └── brand-guidelines/   # Brand usage & color/typography specs
├── products/
│   ├── vegetables/         # Master catalogue vegetable photos (.webp)
│   ├── fruits/             # Master catalogue fruit photos (.webp)
│   ├── leafy-vegetables/
│   ├── grains/
│   ├── pulses/
│   ├── spices/
│   ├── oilseeds/
│   └── other-products/
├── categories/             # Category thumbnails (vegetables.png, fruits.png, etc.)
├── banners/                # Customer, farmer, and promotional banners
├── onboarding/             # Onboarding illustrations per app
├── illustrations/          # Empty states, no-internet, location, error states
├── icons/                  # Categories, payment, delivery, and general icons
└── placeholders/           # Fallback placeholders for missing images
```

## Naming Conventions

- Use **lowercase, hyphen-separated** filenames (e.g., `tomato.webp`, `alphonso-mango.webp`, `kisan-setu-logo-primary.svg`).
- Avoid generic names (`image1.png`, `untitled.png`, `final-final.png`).

## Supported Formats

- **WebP / AVIF**: Product photography and banners (optimized size + quality).
- **PNG**: Logos requiring transparency and raster placeholders/categories.
- **SVG**: Vector logos, icons, and illustrations.

## How to Add Assets

1. **New Product Image**: Place `<product-slug>.webp` under `assets/products/<category>/` and reference it in `AppAssets` if static, or upload via Admin Panel for dynamic backend storage.
2. **New Category Image**: Place `<category-slug>.png` under `assets/categories/` and register the constant in `AppAssets`.

## Application Integration

- **Flutter Apps (`apps/customer-app`, `apps/farmer-app`)**:
  - Registered in `pubspec.yaml` under `flutter.assets` via `../../assets/...`.
  - Referenced through `lib/core/constants/app_assets.dart` (`AppAssets`).
- **Admin Panel (`apps/admin-panel`)**:
  - Served from `/assets/...` via `vite.config.ts` (`sharedAssetsPlugin`).
  - Referenced through `src/constants/assets.ts` (`AppAssets`).

## Static vs. Dynamic Images

- **Local / Static**: Branding, logos, placeholders, onboarding, empty-state illustrations, and bundled fallback category/product assets.
- **Dynamic (Backend Storage)**: Master product images (`Product.imageUrl`) and farmer-specific listing images are stored in backend object/file storage with metadata in PostgreSQL.
