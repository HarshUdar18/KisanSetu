import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/subscription_provider.dart';

/// Implements Stitch `subscription_details_schedule`.
class SubscriptionDetailsScreen extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionDetailsScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final sub = provider.getById(subscriptionId);

    if (sub == null) {
      return const Scaffold(
        appBar: KisanStackAppBar(title: 'Subscription Details'),
        body: Center(child: Text('Subscription not found')),
      );
    }

    final isPaused = sub.status == 'PAUSED';
    final isCancelled = sub.status == 'CANCELLED';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Subscription Details'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.weeklyCartTitle,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Frequency: ${sub.frequency}'),
                Text('Status: ${sub.status}'),
                Text('Next Delivery: ${sub.nextDeliveryDate}'),
                Text('Slot: ${sub.deliveryPreferences ?? 'Morning Harvest'}'),
                const SizedBox(height: 8),
                Text(
                  '₹${sub.totalPerCycle.toStringAsFixed(0)} per cycle',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isCancelled) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_calendar, color: AppColors.primary),
                title: const Text('Edit Delivery Schedule & Frequency'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/subscriptions/${sub.id}/edit'),
              ),
            ),
            const SizedBox(height: 8),
            if (isPaused)
              ElevatedButton.icon(
                onPressed: () => provider.resumeSubscription(sub.id),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume Subscription'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => context.push('/subscriptions/${sub.id}/pause'),
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Pause / Vacation Mode'),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final ok = await ConfirmationDialog.show(
                  context,
                  title: 'Cancel Subscription?',
                  message: 'Are you sure you want to cancel ${sub.weeklyCartTitle}?',
                  confirmLabel: 'Yes, Cancel',
                  isDestructive: true,
                );
                if (ok == true) {
                  provider.cancelSubscription(sub.id);
                }
              },
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text('Cancel Subscription',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ],
      ),
    );
  }
}
