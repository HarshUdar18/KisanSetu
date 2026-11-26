import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../../core/widgets/product_card.dart';
import '../providers/catalog_provider.dart';

/// Implements Search, Suggestions, Results, and Stitch `empty_search_recommendations`.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<CatalogProvider>().setSearchQuery(q);
      }
    });
  }

  void _applySearch(String q) {
    _ctrl.text = q;
    context.read<CatalogProvider>().setSearchQuery(q);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final results = catalog.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Search Harvest'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search onions, A2 milk, spinach, FPOs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_ctrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _ctrl.clear();
                        catalog.setSearchQuery('');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primary),
                    onPressed: () => _applySearch('Palak'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Popular & Recent Searches',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: catalog.recentSearches
                .map((s) => ActionChip(
                      label: Text(s),
                      onPressed: () => _applySearch(s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          if (results.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text(
                    'No Direct Harvest Matches Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try searching for "Onions", "Spinach", "A2 Milk", or clear your search to view all morning harvests.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      _ctrl.clear();
                      catalog.resetFilters();
                    },
                    child: const Text('Show All Fresh Produce'),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (_, index) => ProductCard(product: results[index]),
            ),
        ],
      ),
    );
  }
}
