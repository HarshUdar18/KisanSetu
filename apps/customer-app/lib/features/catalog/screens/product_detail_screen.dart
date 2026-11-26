import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_gate.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../../core/widgets/product_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/catalog_provider.dart';

/// Implements Stitch `product_details`.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _qty = 1.0;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final product = catalog.getById(widget.productId);

    if (product == null) {
      return const Scaffold(
        appBar: KisanStackAppBar(title: 'Product Details'),
        body: Center(child: Text('Product not found')),
      );
    }

    final similar = catalog.allProducts
        .where((p) => p.id != product.id)
        .take(2)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(
        title: 'Product Details',
        actions: [
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.margin),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: AppShadows.level3,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_qty > 1) setState(() => _qty -= 1);
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      _qty.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    IconButton(
                      onPressed: () => setState(() => _qty += 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!context.read<AuthProvider>().isAuthenticated) {
                      await promptGuestSignIn(
                        context,
                        actionDescription: 'add fresh produce to your basket',
                      );
                      return;
                    }
                    final added = await cart.addProduct(product, quantity: _qty);
                    if (!context.mounted || !added) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to Farm Basket'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () => context.push('/cart'),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    'Add • ₹${(product.currentPrice * _qty).toStringAsFixed(0)}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.eco, size: 84, color: AppColors.primaryContainer),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isOrganic
                          ? AppColors.secondaryContainer
                          : AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      product.isOrganic ? '100% Organic Certified' : 'Harvested 4h ago',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            product.categoryName ?? 'Verified FPO Collective',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹${product.currentPrice.toStringAsFixed(0)} / ${product.unit}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (product.previousPrice != null) ...[
                const SizedBox(width: 10),
                Text(
                  '₹${product.previousPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description ??
                'Dawn-harvested produce sourced directly from verified Maharashtra FPOs with transparent farmgate pricing.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Farmer Origin Card
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.agriculture, color: Colors.white),
              ),
              title: const Text('Sourced from Ramesh Shinde (Junnar FPO)'),
              subtitle: const Text('Tap to view farm origin story & certifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/farmer/fpo-mahyco'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.tertiaryFixed,
                child: Icon(Icons.star, color: AppColors.onTertiaryFixed),
              ),
              title: const Text('4.9 ★ Customer & Harvest Reviews'),
              subtitle: const Text('Read feedback or send a note to the farmer'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/product/${product.id}/reviews'),
            ),
          ),
          if (similar.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Similar Morning Harvests',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: similar.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (_, i) => ProductCard(product: similar[i]),
            ),
          ],
        ],
      ),
    );
  }
}
