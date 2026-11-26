/// Centralized asset path constants for the Kisan Setu Customer App.
///
/// All static visual assets live in the root `assets/` directory and are
/// exposed to Flutter via the `assets/` junction and registered in `pubspec.yaml`.
class AppAssets {
  AppAssets._();

  // Branding & Logos
  static const String farmToMarketBadge =
      'assets/branding/logo/kisan-setu-farm-to-market-badge.png';
  static const String wordmark =
      'assets/branding/logo/kisan-setu-wordmark.jpg';
  static const String logoPrimary = farmToMarketBadge;
  static const String logoPrimarySvg =
      'assets/branding/logo/kisan-setu-logo-primary.svg';
  static const String logoWhite =
      'assets/branding/logo/kisan-setu-logo-white.png';
  static const String logoDark =
      'assets/branding/logo/kisan-setu-logo-dark.png';
  static const String appIcon =
      'assets/branding/logo/kisan-setu-icon.png';

  // Placeholders
  static const String productPlaceholder =
      'assets/placeholders/product-placeholder.png';
  static const String farmerPlaceholder =
      'assets/placeholders/farmer-placeholder.png';
  static const String categoryPlaceholder =
      'assets/placeholders/category-placeholder.png';
  static const String bannerPlaceholder =
      'assets/placeholders/banner-placeholder.png';

  // Categories
  static const String categoryVegetables =
      'assets/categories/vegetables.png';
  static const String categoryFruits = 'assets/categories/fruits.png';
  static const String categoryLeafyVegetables =
      'assets/categories/leafy-vegetables.png';
  static const String categoryGrains = 'assets/categories/grains.png';
  static const String categoryPulses = 'assets/categories/pulses.png';
  static const String categorySpices = 'assets/categories/spices.png';

  // Common Master Products
  static const String tomato = 'assets/products/vegetables/tomato.webp';
  static const String onion = 'assets/products/vegetables/onion.webp';
  static const String potato = 'assets/products/vegetables/potato.webp';
  static const String alphonsoMango =
      'assets/products/fruits/alphonso-mango.webp';
}
