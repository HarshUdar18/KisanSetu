import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';

/// Top sticky header matching Stitch `mobile_tab` shell (`home_dashboard`, `weekly_cart_planner`, etc.).
class KisanTabHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLocationTap;

  const KisanTabHeader({super.key, this.onLocationTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final cartCount = context.watch<CartProvider>().cart.itemCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        boxShadow: AppShadows.level1,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            child: Row(
              children: [
                // Brand Mark
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.eco, color: AppColors.harvestGold, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Delivery Location Pill
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    onTap: onLocationTap ?? () => context.push('/select-location'),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Deliver to: ${settings.formattedDeliveryLocation}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const Icon(Icons.expand_more, color: AppColors.outline, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Search
                IconButton(
                  tooltip: 'Search produce',
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                ),
                // Cart with Harvest Gold badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      tooltip: 'Shopping Cart',
                      onPressed: () => context.push('/cart'),
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: AppColors.onSurfaceVariant),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.tertiaryFixedDim,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onTertiaryFixed,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Profile Avatar
                InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, color: AppColors.onPrimary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Top AppBar matching Stitch `mobile_stack` shell.
class KisanStackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const KisanStackAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: onBack ?? () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: actions,
    );
  }
}
