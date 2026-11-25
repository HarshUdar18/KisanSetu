import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../../core/widgets/product_card.dart';
import '../providers/catalog_provider.dart';

/// Implements Stitch `product_categories`.
class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;

  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final catalog = context.read<CatalogProvider>();
      if (catalog.allProducts.isEmpty) {
        catalog.loadCatalog();
      }
      if (widget.initialCategory != null) {
        catalog.selectCategory(widget.initialCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Farm Categories', style: Theme.of(context).textTheme.headlineMedium),
              OutlinedButton.icon(
                onPressed: () => context.push('/catalog'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filter & Sort'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All Produce'),
                    selected: catalog.selectedCategoryId == null,
                    onSelected: (_) => catalog.selectCategory(null),
                  ),
                ),
                ...catalog.categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: catalog.selectedCategoryId == c.id,
                        onSelected: (_) => catalog.selectCategory(c.id),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
