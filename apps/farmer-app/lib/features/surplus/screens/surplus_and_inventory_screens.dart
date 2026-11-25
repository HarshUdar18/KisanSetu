import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../produce/providers/produce_provider.dart';

/// Implements Stitch `surplus_produce_management`.
class SurplusScreen extends StatelessWidget {
  const SurplusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produce = context.watch<ProduceProvider>();
    final items = produce.surplusListings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Surplus Produce Management'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/surplus/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('List Surplus Batch'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Active Surplus Batches (${items.length})',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          ...items.map((lot) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(lot.cropName),
                  subtitle: Text(
                      '${lot.availableQty.toStringAsFixed(0)} ${lot.unit} • ₹${lot.pricePerUnit.toStringAsFixed(0)}/${lot.unit}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => produce.deleteListing(lot.id),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// Implements Stitch `list_surplus_batch`.
class AddSurplusScreen extends StatefulWidget {
  const AddSurplusScreen({super.key});

  @override
  State<AddSurplusScreen> createState() => _AddSurplusScreenState();
}

class _AddSurplusScreenState extends State<AddSurplusScreen> {
  final _nameCtrl = TextEditingController(text: 'Surplus Red Onions');
  final _qtyCtrl = TextEditingController(text: '250');
  final _priceCtrl = TextEditingController(text: '22');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'List Surplus Batch'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Surplus Produce Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Surplus Quantity (kg)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Expected Bulk Price (₹/kg)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProduceProvider>().createListing(
                    FarmerListing(
                      id: 'SUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      productId: 'prod-surplus',
                      cropName: _nameCtrl.text.trim(),
                      marathiName: '',
                      category: 'Surplus',
                      variety: 'Bulk Lot',
                      availableQty: double.tryParse(_qtyCtrl.text) ?? 100,
                      unit: 'kg',
                      pricePerUnit: double.tryParse(_priceCtrl.text) ?? 20,
                      qualityGrade: 'Grade B Bulk',
                      harvestDate: 'Ready Now',
                      isSurplus: true,
                    ),
                  );
              if (!context.mounted) return;
              context.pop();
            },
            child: const Text('Publish Surplus Batch'),
          ),
        ],
      ),
    );
  }
}

/// Module 12: Inventory Management Dashboard.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produce = context.watch<ProduceProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Produce Inventory Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: produce.listings
            .map((lot) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(lot.cropName),
                    subtitle: Text(
                        'Available: ${lot.availableQty.toStringAsFixed(0)} ${lot.unit} • Reserved: ${lot.committedQty.toStringAsFixed(0)} ${lot.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (lot.availableQty >= 10) {
                              produce.updateListing(lot.id,
                                  qty: lot.availableQty - 10);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => produce.updateListing(lot.id,
                              qty: lot.availableQty + 10),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
