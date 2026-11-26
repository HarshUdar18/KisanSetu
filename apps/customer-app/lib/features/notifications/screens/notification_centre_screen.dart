import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/notifications_provider.dart';

/// Implements Stitch `notification_centre` & `empty_notifications`.
class NotificationCentreScreen extends StatelessWidget {
  const NotificationCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: KisanStackAppBar(
        title: 'Notification Centre',
        actions: [
          IconButton(
            tooltip: 'Preferences',
            onPressed: () => context.push('/notification-preferences'),
            icon: const Icon(Icons.tune),
          ),
          if (items.isNotEmpty)
            TextButton(
              onPressed: provider.markAllRead,
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: 'All Caught Up in the Fields!',
              subtitle: 'You have no unread harvest, order, or payout notifications.',
              actionLabel: 'Browse Fresh Produce',
              onAction: () => context.go('/home'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.margin),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = items[index];
                final unread = n['read'] == false;
                return Card(
                  color: unread
                      ? AppColors.surfaceContainerLow
                      : AppColors.surfaceContainerLowest,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: unread
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainer,
                      child: Icon(
                        n['type'] == 'ORDER'
                            ? Icons.local_shipping_outlined
                            : n['type'] == 'PAYMENT'
                                ? Icons.account_balance_wallet_outlined
                                : Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      n['title'] as String,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    subtitle: Text('${n['body']}\n${n['time']}'),
                    isThreeLine: true,
                    onTap: () => provider.markAsRead(n['id'] as String),
                  ),
                );
              },
            ),
    );
  }
}
