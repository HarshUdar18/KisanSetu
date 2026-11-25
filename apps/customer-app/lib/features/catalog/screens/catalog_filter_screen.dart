import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../../core/widgets/product_card.dart';
import '../providers/catalog_provider.dart';

/// Implements Stitch `product_catalog_filters_sorting`.
class CatalogFilterScreen extends StatelessWidget {
  const CatalogFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(
        title: 'Filter & Refine Produce',
        actions: [
          TextButton(
            onPressed: catalog.resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Organic Certified'),
                selected: catalog.onlyOrganic,
                onSelected: (v) => catalog.setFilters(onlyOrganic: v),
              ),
              FilterChip(
                label: const Text('Price: Low to High'),
                selected: catalog.sortBy == 'price_low',
                onSelected: (v) =>
                    catalog.setFilters(sortBy: v ? 'price_low' : 'relevance'),
              ),
              FilterChip(
                label: const Text('Price: High to Low'),
                selected: catalog.sortBy == 'price_high',
                onSelected: (v) =>
                    catalog.setFilters(sortBy: v ? 'price_high' : 'relevance'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Showing ${products.length} fresh harvest items',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (_, index) => ProductCard(product: products[index]),
          ),
        ],
      ),
    );
  }
}
