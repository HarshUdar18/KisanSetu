import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `notification_preferences`.
class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Notification Preferences'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          SwitchListTile(
            title: const Text('Order Updates'),
            subtitle: const Text('Harvest packed, hub arrival, out for delivery'),
            value: settings.orderUpdates,
            onChanged: (v) => settings.updateNotificationPreference(order: v),
          ),
          SwitchListTile(
            title: const Text('Payment Updates'),
            subtitle: const Text('UPI verification & direct farmer payout receipts'),
            value: settings.paymentUpdates,
            onChanged: (v) => settings.updateNotificationPreference(payment: v),
          ),
          SwitchListTile(
            title: const Text('Delivery Updates'),
            subtitle: const Text('Morning doorstep arrival & EV partner alerts'),
            value: settings.deliveryUpdates,
            onChanged: (v) => settings.updateNotificationPreference(delivery: v),
          ),
          SwitchListTile(
            title: const Text('Weekly Cart Reminders'),
            subtitle: const Text('9:00 PM dispatch cutoff reminders'),
            value: settings.weeklyCartReminders,
            onChanged: (v) => settings.updateNotificationPreference(weeklyCart: v),
          ),
          SwitchListTile(
            title: const Text('Subscription Reminders'),
            subtitle: const Text('Daily A2 milk & vacation resume alerts'),
            value: settings.subscriptionReminders,
            onChanged: (v) =>
                settings.updateNotificationPreference(subscription: v),
          ),
          SwitchListTile(
            title: const Text('Offers & Seasonal Harvests'),
            subtitle: const Text('Nashik grape & Alphonso mango season alerts'),
            value: settings.promotions,
            onChanged: (v) => settings.updateNotificationPreference(promo: v),
          ),
          SwitchListTile(
            title: const Text('Important Account Notifications'),
            subtitle: const Text('Security & active session alerts'),
            value: settings.accountAlerts,
            onChanged: (v) => settings.updateNotificationPreference(account: v),
          ),
        ],
      ),
    );
  }
}
