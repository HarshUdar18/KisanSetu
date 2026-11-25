import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/orders_provider.dart';

/// Implements Stitch `cancel_order` and `order_cancellation_confirmation`.
class CancelOrderScreen extends StatefulWidget {
  final String orderId;

  const CancelOrderScreen({super.key, required this.orderId});

  @override
  State<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  String _reason = 'Need to change delivery date or slot';
  bool _cancelled = false;

  static const _reasons = [
    'Need to change delivery date or slot',
    'Ordered by mistake / duplicate order',
    'Want to add more items via Weekly Cart',
    'Delivery address needs correction',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Cancel Order'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: _cancelled
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.check, size: 48, color: AppColors.onSecondaryContainer),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Order Cancelled',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Order #${widget.orderId} has been cancelled before harvest cutoff. Any prepaid amount will be refunded within 24–48 hours.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/orders'),
                      child: const Text('Back to My Orders'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.tertiary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pre-Harvest Window Active: Cancelling now prevents farmers from harvesting unnecessarily.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Select Cancellation Reason',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  ..._reasons.map((r) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<String>(
                          value: r,
                          groupValue: _reason,
                          onChanged: (v) => setState(() => _reason = v!),
                          title: Text(r, style: const TextStyle(fontSize: 14)),
                        ),
                      )),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () {
                        context
                            .read<OrdersProvider>()
                            .cancelOrder(widget.orderId, _reason);
                        setState(() => _cancelled = true);
                      },
                      child: const Text('Confirm Cancellation'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
