import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/product_loading_skeleton.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../location/providers/address_provider.dart';
import '../../weekly_cart/providers/weekly_cart_provider.dart';

/// Customer Dashboard (`home_dashboard`).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialLoadTriggered = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDashboardData);
  }

  Future<void> _loadDashboardData() async {
    if (!mounted || _initialLoadTriggered) return;
    _initialLoadTriggered = true;

    final auth = context.read<AuthProvider>();
    final catalog = context.read<CatalogProvider>();
    final cart = context.read<CartProvider>();
    final addresses = context.read<AddressProvider>();
    final weekly = context.read<WeeklyCartProvider>();

    await Future.wait([
      if (catalog.allProducts.isEmpty) catalog.loadCatalog(),
      if (auth.isAuthenticated) ...[
        cart.fetchCart(),
        if (addresses.addresses.isEmpty) addresses.fetchAddresses(),
        weekly.fetchWeeklyCarts(),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final auth = context.watch<AuthProvider>();
    final weekly = context.watch<WeeklyCartProvider>();
    final products = catalog.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanTabHeader(),
      body: catalog.isLoading && products.isEmpty
          ? const ProductLoadingSkeleton()
          : RefreshIndicator(
              onRefresh: catalog.loadCatalog,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  // Greeting + Search Bar with Voice Input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, ${auth.greetingFirstName}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => context.push('/search'),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: AppShadows.level1,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: AppColors.outline, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Search vegetables, pulses, or FPOs...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.outline),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () => context.push('/search'),
                                  icon: const Icon(Icons.mic,
                                      color: AppColors.primary, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seasonal Hero Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.level2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryFixed,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: const Text(
                                  'SEASONAL SPECIAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onTertiaryFixed,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Direct from Vineyard',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nashik Grape Harvest Season is Here!',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Direct from Sahyadri Farmers Collective. 25% Off First 500 Baskets.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.surfaceContainerHigh,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/catalog'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.harvestGold,
                              foregroundColor: AppColors.onTertiaryFixed,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Shop Now'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4 Quick Action Shortcuts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _QuickShortcut(
                          icon: Icons.calendar_month,
                          label: 'Weekly Cart',
                          badge: 'PLAN AHEAD',
                          onTap: () => context.go('/weekly-planner'),
                        ),
                        const SizedBox(width: 8),
                        _QuickShortcut(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Fresh Harvest',
                          iconBg: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                          iconColor: AppColors.tertiary,
                          onTap: () => context.push('/catalog'),
                        ),
                        const SizedBox(width: 8),
                        _QuickShortcut(
                          icon: Icons.verified_outlined,
                          label: 'FPO Organic',
                          onTap: () {
                            catalog.setFilters(onlyOrganic: true);
                            context.push('/catalog');
                          },
                        ),
                        const SizedBox(width: 8),
                        _QuickShortcut(
                          icon: Icons.autorenew,
                          label: 'Subscriptions',
                          onTap: () => context.push('/subscriptions'),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal Category Chips
                  SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: catalog.selectedCategoryId == null,
                            onSelected: (_) => catalog.selectCategory(null),
                          ),
                        ),
                        ...catalog.categories.map((cat) {
                          final selected = catalog.selectedCategoryId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat.name),
                              selected: selected,
                              onSelected: (_) => catalog.selectCategory(cat.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Morning Harvest Specials
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 4,
                                backgroundColor: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Morning Harvest Specials',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/catalog'),
                          child: const Text('PICKED TODAY'),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length > 4 ? 4 : products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 252,
                      ),
                      itemBuilder: (context, index) =>
                          ProductCard(product: products[index]),
                    ),
                  ),

                  // Meet Your Farmers (FPO Spotlight)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Meet Your Farmers',
                            style: Theme.of(context).textTheme.headlineSmall),
                        TextButton(
                          onPressed: () => context.push('/fpo-network'),
                          child: const Text('FPO Spotlight'),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppShadows.level1,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Verified FPO Producer Network',
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified,
                                            size: 16, color: AppColors.primary),
                                      ],
                                    ),
                                    Text(
                                      'Direct from local Farmer Producer Organizations',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'LIVE CATALOGUE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                      Text(
                                        '${products.length} fresh items available',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => context.push('/fpo-network'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: const Text('Explore FPOs',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Weekly Basket Reminder Banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: InkWell(
                      onTap: () => context.go('/weekly-planner'),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: const Icon(Icons.calendar_today,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Weekly Kitchen Basket',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(
                                    weekly.activeWeeklyCart != null
                                        ? 'Est. ₹${weekly.activeWeeklyCart!.weeklyEstimatedTotal.toStringAsFixed(0)} • Finalize by 9:00 PM'
                                        : 'Plan Mon–Sun fresh veggies & A2 milk',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuickShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? iconBg;
  final Color? iconColor;
  final VoidCallback onTap;

  const _QuickShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.iconBg,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppShadows.level1,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: iconBg ?? AppColors.surfaceContainer,
                    child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: -6,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixedDim,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onTertiaryFixed,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
