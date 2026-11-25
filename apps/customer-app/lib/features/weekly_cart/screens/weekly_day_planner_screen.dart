import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../models/weekly_cart_model.dart';
import '../providers/weekly_cart_provider.dart';

/// Implements Stitch `weekly_cart_day_planner_monday_plan` (for any Mon–Sun day).
class WeeklyDayPlannerScreen extends StatefulWidget {
  final String day;

  const WeeklyDayPlannerScreen({super.key, required this.day});

  @override
  State<WeeklyDayPlannerScreen> createState() => _WeeklyDayPlannerScreenState();
}

class _WeeklyDayPlannerScreenState extends State<WeeklyDayPlannerScreen> {
  late List<WeeklyCartItemModel> _items;

  @override
  void initState() {
    super.initState();
    final existing = context.read<WeeklyCartProvider>().getDayPlan(widget.day);
    _items = List<WeeklyCartItemModel>.from(existing?.items ?? []);
    Future.microtask(() {
      if (!mounted) return;
      final catalog = context.read<CatalogProvider>();
      if (catalog.allProducts.isEmpty) catalog.loadCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final weekly = context.watch<WeeklyCartProvider>();
    final dayTotal = _items.fold<double>(0.0, (s, i) => s + i.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(title: '${widget.day} Harvest Plan'),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.margin),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: AppShadows.level3,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DAY SUBTOTAL',
                      style: TextStyle(fontSize: 10, color: AppColors.outline)),
                  Text('₹${dayTotal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final ok = await weekly.updateDayItems(widget.day, _items);
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(weekly.errorMessage ?? 'Locked')),
                    );
                    return;
                  }
                  context.pop();
                },
                child: const Text('Save Day Plan'),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('${widget.day} Morning Dawn Delivery',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (_items.isNotEmpty) ...[
            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Text('₹${item.unitPrice.toStringAsFixed(0)} / ${item.unit}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (item.quantity <= 1) {
                              _items.removeAt(idx);
                            } else {
                              final q = item.quantity - 1;
                              _items[idx] = WeeklyCartItemModel(
                                id: item.id,
                                productId: item.productId,
                                productName: item.productName,
                                unit: item.unit,
                                quantity: q,
                                unitPrice: item.unitPrice,
                                totalPrice: q * item.unitPrice,
                              );
                            }
                          });
                        },
                      ),
                      Text(item.quantity.toStringAsFixed(0)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            final q = item.quantity + 1;
                            _items[idx] = WeeklyCartItemModel(
                              id: item.id,
                              productId: item.productId,
                              productName: item.productName,
                              unit: item.unit,
                              quantity: q,
                              unitPrice: item.unitPrice,
                              totalPrice: q * item.unitPrice,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 24),
          ],
          Text('Add Produce to ${widget.day}',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...catalog.allProducts.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('₹${p.currentPrice.toStringAsFixed(0)} / ${p.unit}'),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                    onPressed: () {
                      setState(() {
                        _items.add(WeeklyCartItemModel(
                          id: 'wi-${DateTime.now().millisecondsSinceEpoch}',
                          productId: p.id,
                          productName: p.name,
                          unit: p.unit,
                          quantity: 1,
                          unitPrice: p.currentPrice,
                          totalPrice: p.currentPrice,
                        ));
                      });
                    },
                    child: const Text('+ Add'),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
