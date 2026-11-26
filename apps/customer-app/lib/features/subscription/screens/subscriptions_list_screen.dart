import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_gate.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/subscription_provider.dart';

/// Implements Stitch `subscription_overview`.
class SubscriptionsListScreen extends StatefulWidget {
  const SubscriptionsListScreen({super.key});

  @override
  State<SubscriptionsListScreen> createState() =>
      _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState extends State<SubscriptionsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<SubscriptionProvider>().fetchSubscriptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        appBar: KisanStackAppBar(title: 'Farm Subscriptions'),
        body: GuestAuthRequiredView(
          icon: Icons.autorenew,
          title: 'Sign in to manage subscriptions',
          subtitle: 'Create or pause recurring A2 milk and farm produce plans.',
        ),
      );
    }
    final provider = context.watch<SubscriptionProvider>();
    final subs = provider.subscriptions;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Farm Subscriptions'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-subscription'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Subscription'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECURRING HARVEST PLANS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tertiaryFixed,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Why Subscribe with Kisan Setu?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lock guaranteed morning A2 milk and fresh greens, pause anytime for vacations, and support steady farmer income.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your Subscription Plans',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ...subs.map((s) {
            final isActive = s.status == 'ACTIVE';
            final isPaused = s.status == 'PAUSED';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: isActive
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainer,
                  child: Icon(
                    Icons.autorenew,
                    color: isActive
                        ? AppColors.onSecondaryContainer
                        : AppColors.outline,
                  ),
                ),
                title: Text(
                  s.weeklyCartTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${s.frequency} • ₹${s.totalPerCycle.toStringAsFixed(0)}/cycle\nNext: ${s.nextDeliveryDate}',
                  ),
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.secondaryContainer
                            : isPaused
                            ? AppColors.tertiaryFixed
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        s.status,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => context.push('/subscriptions/${s.id}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
