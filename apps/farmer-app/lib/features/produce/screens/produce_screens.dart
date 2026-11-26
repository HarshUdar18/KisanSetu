import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/farmer_header.dart';
import '../providers/produce_provider.dart';

/// Implements Stitch `my_produce_management`.
class MyProduceScreen extends StatelessWidget {
  const MyProduceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final produce = context.watch<ProduceProvider>();
    final lots = produce.listings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerTabHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/produce/add-category'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Lot'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Produce Lots (${lots.length})',
                  style: Theme.of(context).textTheme.headlineMedium),
              TextButton(
                onPressed: () => context.push('/produce/sowing-schedule'),
                child: const Text('Sowing Plan'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...lots.map((lot) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: lot.status == 'ACTIVE'
                                  ? AppColors.secondaryContainer
                                  : AppColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '${lot.qualityGrade} • ${lot.status}',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(lot.harvestDate,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(lot.cropName,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        '₹${lot.pricePerUnit.toStringAsFixed(0)}/${lot.unit} • Available: ${lot.availableQty.toStringAsFixed(0)} ${lot.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 36)),
                            onPressed: () =>
                                context.push('/produce/lot/${lot.id}'),
                            icon: const Icon(Icons.qr_code_2, size: 16),
                            label: const Text('Batch QR'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 36)),
                            onPressed: () {
                              final nextStatus =
                                  lot.status == 'ACTIVE' ? 'PAUSED' : 'ACTIVE';
                              produce.updateListing(lot.id, status: nextStatus);
                            },
                            child: Text(
                                lot.status == 'ACTIVE' ? 'Pause' : 'Resume'),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () async {
                              final ok = await ConfirmationDialog.show(
                                context,
                                title: 'Delete Produce Lot?',
                                message: 'Remove ${lot.cropName} from active listings?',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                              );
                              if (ok == true) produce.deleteListing(lot.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

/// Implements Stitch `add_new_produce_crop_category`.
class AddProduceCategoryScreen extends StatefulWidget {
  const AddProduceCategoryScreen({super.key});

  @override
  State<AddProduceCategoryScreen> createState() =>
      _AddProduceCategoryScreenState();
}

class _AddProduceCategoryScreenState extends State<AddProduceCategoryScreen> {
  String _category = 'Leafy Greens';
  String _crop = 'Fresh Baby Spinach (पालक)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Add Produce — Crop & Category'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Select Crop Category',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Leafy Greens', 'Vegetables', 'Fruits', 'Grains & Pulses']
                .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Select Produce', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...[
            'Fresh Baby Spinach (पालक)',
            'Desi Red Tomatoes (टोमॅटो)',
            'Coriander & Mint (कोथिंबीर)',
            'Tender Bhindi (भेंडी)',
            'Purandar Sweet Figs (अंजीर)',
          ].map((crop) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(crop),
                  trailing: Icon(
                    _crop == crop ? Icons.check_circle : Icons.chevron_right,
                    color: _crop == crop ? AppColors.primary : AppColors.outline,
                  ),
                  onTap: () => setState(() => _crop = crop),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/produce/add-details', extra: {
              'category': _category,
              'crop': _crop,
            }),
            child: const Text('Next: Quantity, Price & Harvest ->'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `add_new_produce_quantity_price_harvest`.
class AddProduceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const AddProduceDetailsScreen({super.key, this.data = const {}});

  @override
  State<AddProduceDetailsScreen> createState() =>
      _AddProduceDetailsScreenState();
}

class _AddProduceDetailsScreenState extends State<AddProduceDetailsScreen> {
  final _qtyCtrl = TextEditingController(text: '100');
  final _priceCtrl = TextEditingController(text: '36');
  String _grade = 'Organic A+';
  String _unit = 'kg';

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.data['crop'] as String? ?? 'Fresh Baby Spinach (पालक)';
    final category = widget.data['category'] as String? ?? 'Leafy Greens';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Quantity, Price & Harvest'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text(crop, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Available Quantity'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Farmgate Price per Unit (₹)'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['kg', 'bundle', 'crate', 'quintal']
                .map((u) => ChoiceChip(
                      label: Text(u),
                      selected: _unit == u,
                      onSelected: (_) => setState(() => _unit = u),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Organic A+', 'Grade A', 'Standard']
                .map((g) => ChoiceChip(
                      label: Text(g),
                      selected: _grade == g,
                      onSelected: (_) => setState(() => _grade = g),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
              final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
              final ok = await context.read<ProduceProvider>().createListing(
                    FarmerListing(
                      id: '',
                      productId: '',
                      cropName: crop,
                      marathiName: '',
                      category: category,
                      variety: 'Farm Direct',
                      availableQty: qty,
                      unit: _unit,
                      pricePerUnit: price,
                      qualityGrade: _grade,
                      harvestDate: 'Tomorrow Dawn',
                    ),
                  );
              if (!context.mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produce Lot Published Successfully!')),
                );
                context.go('/produce');
              }
            },
            child: const Text('Publish Produce Lot'),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `produce_lot_details_qr_stamping`.
class ProduceLotQrScreen extends StatelessWidget {
  final String lotId;

  const ProduceLotQrScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    final lot = context.watch<ProduceProvider>().getById(lotId);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FarmerStackAppBar(title: 'Lot Details & QR ($lotId)'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2, size: 140, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(lotId, style: Theme.of(context).textTheme.headlineSmall),
                    Text(lot?.cropName ?? 'Produce Lot'),
                    Text(
                      '${lot?.availableQty.toStringAsFixed(0) ?? '100'} ${lot?.unit ?? 'kg'} • ${lot?.qualityGrade ?? 'Grade A'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/collection/gate-pass'),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Book Collection Hub Gate Pass'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Implements Stitch `crop_portfolio_sowing_schedule`.
class SowingScheduleScreen extends StatelessWidget {
  const SowingScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Rabi Sowing Schedule'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Plot A-1: Baby Spinach (Palak)'),
              subtitle: Text('Sowed: 10 Nov • Expected Harvest: 05 Dec (25 days)'),
              trailing: Chip(label: Text('On Track')),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Plot B-2: Desi Tomatoes'),
              subtitle: Text('Sowed: 02 Oct • Active Picking Phase'),
              trailing: Chip(label: Text('Harvesting')),
            ),
          ),
        ],
      ),
    );
  }
}
