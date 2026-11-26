import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../settlements/providers/settlements_provider.dart';

/// Module 17: Farmer Store & CHC Machinery backed by `/api/v1/farmer-store/products`.
class FarmerStoreScreen extends StatefulWidget {
  const FarmerStoreScreen({super.key});

  @override
  State<FarmerStoreScreen> createState() => _FarmerStoreScreenState();
}

class _FarmerStoreScreenState extends State<FarmerStoreScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context.read<DioClient>().get('/farmer-store/products');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _products = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load store products. Tap retry.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settlements = context.watch<SettlementsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FarmerStackAppBar(
        title: 'FPO Agri Input Store',
        actions: [
          IconButton(
            onPressed: () => context.push('/store/checkout'),
            icon: Badge(
              isLabelVisible: settlements.storeCart.isNotEmpty,
              label: Text('${settlements.storeCart.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('Bio-Fertilizer Booking'),
                onPressed: () => context.push('/store/bio-fertilizer'),
              ),
              ActionChip(
                label: const Text('Group Pool Discount'),
                onPressed: () => context.push('/store/group-pool'),
              ),
              ActionChip(
                label: const Text('Machinery CHC'),
                onPressed: () => context.push('/store/chc'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(_error!),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _loadProducts, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (_products.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No store products available yet.'),
              ),
            )
          else
            ..._products.map((p) {
              final subsidyPrice = (p['subsidizedPrice'] ?? p['subsidyPrice'] ?? 0) as num;
              final mrp = (p['mrp'] ?? 0) as num;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text((p['name'] ?? '').toString(),
                      style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(
                      '${p['category'] ?? ''} • ${p['unit'] ?? ''}\nSubsidized: ₹${subsidyPrice.toStringAsFixed(0)} (MRP ₹${mrp.toStringAsFixed(0)})'),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36)),
                    onPressed: () {
                      settlements.addToStoreCart({
                        ...p,
                        'subsidyPrice': subsidyPrice,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${p['name']} added to Store Cart')),
                      );
                    },
                    child: const Text('+ Add'),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class BioFertilizerScreen extends StatelessWidget {
  const BioFertilizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Subsidized Bio-Fertilizer Booking'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Book subsidized organic Prom & Bio-Fertilizer through Mulshi FPO.'),
        ),
      ),
    );
  }
}

class GroupPoolScreen extends StatelessWidget {
  const GroupPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Input Group Purchase Pool'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Rabi Sowing Mega Pool: 42 farmers joined • 28% bulk discount unlocked.'),
        ),
      ),
    );
  }
}

class StoreCheckoutScreen extends StatelessWidget {
  const StoreCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettlementsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'FPO Input Order Summary'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Expanded(
              child: s.storeCart.isEmpty
                  ? const Center(child: Text('Your FPO Store cart is empty.'))
                  : ListView.builder(
                      itemCount: s.storeCart.length,
                      itemBuilder: (_, i) {
                        final item = s.storeCart[i];
                        return Card(
                          child: ListTile(
                            title: Text(item['name'] as String),
                            subtitle: Text('Qty: ${item['qty']}'),
                            trailing: Text(
                                '₹${((item['subsidyPrice'] as num) * (item['qty'] as int)).toStringAsFixed(0)}'),
                          ),
                        );
                      },
                    ),
            ),
            if (s.storeCart.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    s.clearStoreCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Prototype FPO requisition submitted for approval.')),
                    );
                    context.pop();
                  },
                  child: Text(
                      'Submit Requisition • ₹${s.storeCartTotal.toStringAsFixed(0)}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChcMachineryScreen extends StatelessWidget {
  const ChcMachineryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Custom Hiring Center (CHC)'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('45 HP Tractor + Rotavator'),
              subtitle: Text('Mulshi CHC • ₹650/hour (Subsidized Member Rate)'),
              trailing: Chip(label: Text('Available')),
            ),
          ),
        ],
      ),
    );
  }
}
