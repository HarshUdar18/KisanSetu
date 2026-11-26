import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../catalog/models/product_model.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../location/providers/address_provider.dart';
import '../providers/subscription_provider.dart';

/// Backend-driven Subscription Creation backed by live catalogue & centralized delivery slots.
class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  State<CreateSubscriptionScreen> createState() =>
      _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  final Map<String, int> _selectedQuantities = {};
  String _frequency = 'WEEKLY';
  String _slotLabel = '';
  List<Map<String, dynamic>> _slots = const [];
  bool _loadingSlots = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final catalog = context.read<CatalogProvider>();
      final dio = context.read<AddressProvider>().dioClient;
      if (catalog.allProducts.isEmpty) {
        await catalog.loadCatalog();
      }
      if (!mounted) return;
      await _loadSlots(dio);
    });
  }

  Future<void> _loadSlots(dynamic dio) async {
    try {
      final res = await dio
          .get('/delivery-slots', queryParameters: {'slotType': 'SUBSCRIPTION'});
      final raw = (res.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (mounted) {
        setState(() {
          _slots = raw;
          if (raw.isNotEmpty) {
            _slotLabel = raw.first['label'] as String? ?? '';
          }
          _loadingSlots = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addr = context.watch<AddressProvider>().defaultAddress;
    final subProvider = context.watch<SubscriptionProvider>();
    final catalog = context.watch<CatalogProvider>();
    final eligibleProducts = catalog.allProducts
        .where((p) => p.isInStock && p.currentPrice > 0)
        .take(15)
        .toList();

    double subtotal = 0.0;
    for (final p in eligibleProducts) {
      final qty = _selectedQuantities[p.id] ?? 0;
      subtotal += p.currentPrice * qty;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Create Subscription'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Select Fresh Produce for Your Basket',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (catalog.isLoading && eligibleProducts.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (eligibleProducts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No in-stock farmer listings are currently available for subscription.'),
              ),
            )
          else
            ...eligibleProducts.map((ProductModel p) {
              final qty = _selectedQuantities[p.id] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(p.name, style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text('₹${p.currentPrice.toStringAsFixed(2)} / ${p.unit} • ${p.stockStatus.replaceAll('_', ' ')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: qty > 0
                            ? () => setState(() => _selectedQuantities[p.id] = qty - 1)
                            : null,
                      ),
                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _selectedQuantities[p.id] = qty + 1),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.md),
          Text('Delivery Frequency',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['DAILY', 'ALTERNATE_DAYS', 'WEEKLY', 'BIWEEKLY'].map((f) {
              return ChoiceChip(
                label: Text(f.replaceAll('_', ' ')),
                selected: _frequency == f,
                onSelected: (_) => setState(() => _frequency = f),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Subscription Delivery Slot',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (_loadingSlots)
            const LinearProgressIndicator()
          else if (_slots.isEmpty)
            const Text('No active subscription slots configured.')
          else
            Wrap(
              spacing: 8,
              children: _slots.map((s) {
                final label = s['label'] as String? ?? '';
                return ChoiceChip(
                  label: Text(label),
                  selected: _slotLabel == label,
                  onSelected: (_) => setState(() => _slotLabel = label),
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Per-Delivery Subtotal',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('₹${subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: subProvider.isLoading || subtotal <= 0 || _slotLabel.isEmpty
                  ? null
                  : () async {
                      final itemsSummary = eligibleProducts
                          .where((p) => (_selectedQuantities[p.id] ?? 0) > 0)
                          .map((p) => '${p.name} x${_selectedQuantities[p.id]}')
                          .join(', ');
                      final ok = await subProvider.createSubscription(
                        title: itemsSummary,
                        frequency: _frequency,
                        addressId: addr?.id ?? '',
                        totalPerCycle: subtotal,
                        deliveryPreferences: _slotLabel,
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subscription created and linked to backend.')),
                        );
                        context.pop();
                      }
                    },
              child: Text('Start Subscription (₹${subtotal.toStringAsFixed(2)}/delivery)'),
            ),
          ),
        ],
      ),
    );
  }
}
