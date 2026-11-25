import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/orders_provider.dart';

/// Implements Stitch `my_orders` (All / Active / Completed / Cancelled).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders.where((o) {
      if (_filter == 'ACTIVE') {
        return o.status != 'DELIVERED' && o.status != 'CANCELLED';
      }
      if (_filter == 'COMPLETED') return o.status == 'DELIVERED';
      if (_filter == 'CANCELLED') return o.status == 'CANCELLED';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Text('My Harvest Orders',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'ACTIVE', 'COMPLETED', 'CANCELLED'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Here Yet',
              subtitle: 'Your farm-direct orders will appear here once placed.',
              actionLabel: 'Explore Fresh Produce',
              onAction: () => context.go('/home'),
            )
          else
            ...orders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.push('/orders/${order.id}'),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order #${order.orderNumber}',
                                  style: Theme.of(context).textTheme.labelLarge),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: order.status == 'CANCELLED'
                                      ? AppColors.errorContainer
                                      : order.status == 'DELIVERED'
                                          ? AppColors.secondaryContainer
                                          : AppColors.tertiaryFixed,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  order.status.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${order.items.length} items • ${order.deliveryDate}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${order.totalAmount.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Row(
                                children: [
                                  if (order.status != 'CANCELLED')
                                    TextButton(
                                      onPressed: () =>
                                          context.push('/tracking/${order.id}'),
                                      child: const Text('Track'),
                                    ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 36)),
                                    onPressed: () =>
                                        context.push('/orders/${order.id}'),
                                    child: const Text('Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
