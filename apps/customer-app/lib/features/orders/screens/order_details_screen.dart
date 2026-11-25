import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/orders_provider.dart';

/// Implements Stitch `order_tracking_overview` / Order Details.
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().getById(orderId);
    if (order == null) {
      return const Scaffold(
        appBar: KisanStackAppBar(title: 'Order Details'),
        body: Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(title: 'Order #${order.orderNumber}'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.local_shipping, color: AppColors.onSecondaryContainer),
              ),
              title: Text(order.status.replaceAll('_', ' '),
                  style: Theme.of(context).textTheme.labelLarge),
              subtitle: Text('Delivery: ${order.deliveryDate} (${order.deliverySlot})'),
              trailing: TextButton(
                onPressed: () => context.push('/tracking/${order.id}'),
                child: const Text('Track'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Harvest Items (${order.items.length})',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...order.items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.productName),
                  subtitle: Text(
                      '${item.quantity.toStringAsFixed(0)} ${item.unit} × ₹${item.unitPrice.toStringAsFixed(0)}'),
                  trailing: Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              )),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('₹${order.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid'),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () => context.push('/orders/${order.id}/invoice'),
            icon: const Icon(Icons.receipt_outlined),
            label: const Text('View Tax Invoice & Harvest Certificate'),
          ),
          const SizedBox(height: 8),
          if (order.status != 'DELIVERED' && order.status != 'CANCELLED')
            OutlinedButton.icon(
              onPressed: () => context.push('/orders/${order.id}/cancel'),
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text('Cancel Order',
                  style: TextStyle(color: AppColors.error)),
            ),
          TextButton(
            onPressed: () => context.push('/raise-ticket'),
            child: const Text('Report an Issue with This Order'),
          ),
        ],
      ),
    );
  }
}
