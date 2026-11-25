import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/catalog/models/product_model.dart';
import '../theme/app_theme.dart';

/// Product card matching Stitch `home_dashboard` & `DESIGN.md` specifications.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String badgeText;

  const ProductCard({
    super.key,
    required this.product,
    this.badgeText = 'Harvested 4h ago',
  });

  Color _categoryBg(String? catId) {
    switch (catId) {
      case 'cat-fruit':
        return const Color(0xFFF3E5F5);
      case 'cat-dairy':
        return const Color(0xFFFFF8E1);
      case 'cat-grain':
      case 'cat-pulse':
        return const Color(0xFFEFEBE9);
      default:
        return AppColors.surfaceContainer;
    }
  }

  IconData _categoryIcon(String? catId) {
    switch (catId) {
      case 'cat-fruit':
        return Icons.apple;
      case 'cat-dairy':
        return Icons.local_drink_outlined;
      case 'cat-grain':
      case 'cat-pulse':
        return Icons.grain;
      case 'cat-oil':
        return Icons.water_drop_outlined;
      default:
        return Icons.eco;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityForProduct(product.id);
    final itemId = cart.itemIdForProduct(product.id);

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.level1,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Visual placeholder with Harvest Freshness Badge
            Stack(
              children: [
                Container(
                  height: 112,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _categoryBg(product.categoryId),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    _categoryIcon(product.categoryId),
                    size: 46,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.isOrganic
                          ? AppColors.secondaryContainer
                          : AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      product.isOrganic ? 'Grade A Organic' : badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: product.isOrganic
                            ? AppColors.onSecondaryContainer
                            : AppColors.onTertiaryFixed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.categoryName ?? 'Verified FPO',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${product.currentPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${product.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (qty <= 0)
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () => cart.addProduct(product),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 38),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                ),
              )
            else
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                      onPressed: () {
                        if (itemId != null) {
                          cart.updateQuantity(itemId, qty - 1);
                        }
                      },
                    ),
                    Text(
                      qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      onPressed: () => cart.addProduct(product),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
