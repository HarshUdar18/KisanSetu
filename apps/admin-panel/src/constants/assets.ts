/**
 * Centralized asset path constants for the Kisan Setu Admin Panel.
 *
 * Served from the root `assets/` directory via Vite's sharedAssetsPlugin.
 */
export const AppAssets = {
  logoPrimary: '/assets/branding/logo/kisan-setu-logo-primary.svg',
  logoPrimaryPng: '/assets/branding/logo/kisan-setu-logo-primary.png',
  logoWhite: '/assets/branding/logo/kisan-setu-logo-white.png',
  logoDark: '/assets/branding/logo/kisan-setu-logo-dark.png',
  favicon: '/assets/branding/logo/kisan-setu-favicon.png',

  productPlaceholder: '/assets/placeholders/product-placeholder.png',
  farmerPlaceholder: '/assets/placeholders/farmer-placeholder.png',
  categoryPlaceholder: '/assets/placeholders/category-placeholder.png',
  bannerPlaceholder: '/assets/placeholders/banner-placeholder.png',

  categoryVegetables: '/assets/categories/vegetables.png',
  categoryFruits: '/assets/categories/fruits.png',
  categoryLeafyVegetables: '/assets/categories/leafy-vegetables.png',
  categoryGrains: '/assets/categories/grains.png',
  categoryPulses: '/assets/categories/pulses.png',
  categorySpices: '/assets/categories/spices.png',
} as const;
