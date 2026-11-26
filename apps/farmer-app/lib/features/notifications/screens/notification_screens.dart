import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/farmer_header.dart';

class NotificationPrimerScreen extends StatelessWidget {
  const NotificationPrimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Notification Alerts'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.surfaceContainer,
              child: Icon(Icons.notifications_active,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Never Miss Demand, QC, or DBT Payout Alerts',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Receive instant alerts for buyer demand, collection center gate slots, APMC lab grades, weather warnings, and Friday DBT payouts.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  settings.setNotificationPermission(PermissionState.granted);
                  context.pushReplacement('/notifications');
                },
                child: const Text('Allow Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCentreScreen extends StatefulWidget {
  const NotificationCentreScreen({super.key});

  @override
  State<NotificationCentreScreen> createState() =>
      _NotificationCentreScreenState();
}

class _NotificationCentreScreenState extends State<NotificationCentreScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final res = await context.read<DioClient>().get('/notifications');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FarmerStackAppBar(
        title: 'Notification Centre',
        actions: [
          IconButton(
            onPressed: () => context.push('/notification-preferences'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _items.isEmpty
          ? const EmptyStateView(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              subtitle: 'All farm, order, and settlement alerts are caught up.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.margin),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _items[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryContainer,
                      child: Icon(Icons.notifications,
                          color: AppColors.onSecondaryContainer),
                    ),
                    title: Text(n['title'] as String),
                    subtitle: Text('${n['body']}\n${n['time']}'),
                    isThreeLine: true,
                    onTap: () => setState(() => n['read'] = true),
                  ),
                );
              },
            ),
    );
  }
}

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Notification Preferences'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          SwitchListTile(
            title: const Text('Order & Demand Alerts'),
            value: s.orderNotifs,
            onChanged: (v) => s.updateNotificationPref(order: v),
          ),
          SwitchListTile(
            title: const Text('Payment & Weekly Settlement Alerts'),
            value: s.settlementNotifs,
            onChanged: (v) => s.updateNotificationPref(settlement: v),
          ),
          SwitchListTile(
            title: const Text('Collection Hub & Gate Pass Alerts'),
            value: s.collectionNotifs,
            onChanged: (v) => s.updateNotificationPref(collection: v),
          ),
          SwitchListTile(
            title: const Text('Quality Inspection (APMC Lab) Alerts'),
            value: s.qcNotifs,
            onChanged: (v) => s.updateNotificationPref(qc: v),
          ),
          SwitchListTile(
            title: const Text('Weather & Spray Window Alerts'),
            value: s.weatherNotifs,
            onChanged: (v) => s.updateNotificationPref(weather: v),
          ),
          SwitchListTile(
            title: const Text('Government Scheme & DBT Updates'),
            value: s.schemeNotifs,
            onChanged: (v) => s.updateNotificationPref(scheme: v),
          ),
        ],
      ),
    );
  }
}
