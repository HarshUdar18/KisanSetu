import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/orders_provider.dart';

/// Implements Stitch `order_fulfillment_supply_chain_tracking` (9-Stage Pipeline).
class TrackingScreen extends StatefulWidget {
  final String orderId;

  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<OrdersProvider>().fetchTracking(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    final tracking = orders.currentTracking;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(
        title: '9-Stage Supply Chain',
        actions: [
          IconButton(
            tooltip: 'Live Delivery Detail',
            onPressed: () => context.push('/tracking/${widget.orderId}/live'),
            icon: const Icon(Icons.local_shipping_outlined),
          ),
        ],
      ),
      body: tracking == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.margin),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.tertiaryFixed,
                        child: Icon(Icons.verified, color: AppColors.onTertiaryFixed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${tracking.orderNumber}',
                              style: const TextStyle(
                                  color: AppColors.onPrimaryContainer, fontSize: 12),
                            ),
                            Text(
                              tracking.currentStatus.replaceAll('_', ' '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push('/tracking/${widget.orderId}/live'),
                        child: const Text('Partner Info',
                            style: TextStyle(color: AppColors.tertiaryFixed)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...tracking.events.map((m) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: m.isCompleted
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHighest,
                            child: Icon(
                              m.isCompleted ? Icons.check : Icons.schedule,
                              size: 16,
                              color: m.isCompleted ? Colors.white : AppColors.outline,
                            ),
                          ),
                          if (m.displayOrder < tracking.events.length)
                            Container(
                              width: 2,
                              height: 36,
                              color: m.isCompleted
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${m.displayOrder}. ${m.title}',
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                  ),
                                  if (m.occurredAt != null)
                                    Text(
                                      m.occurredAt!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                m.description ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => orders.devAdvanceTracking(widget.orderId),
                  icon: const Icon(Icons.fast_forward),
                  label: const Text('Dev Simulator: Advance Next Stage'),
                ),
              ],
            ),
    );
  }
}
