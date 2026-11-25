import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `delivery_harvest_preferences`.
class DeliveryPreferencesScreen extends StatelessWidget {
  const DeliveryPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Delivery & Harvest Preferences'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Morning Harvest Delivery Slot',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...[
            'Morning Harvest (6:00 AM - 8:00 AM)',
            'Mid-Morning (8:00 AM - 10:00 AM)',
            'Evening Fresh (5:00 PM - 7:00 PM)',
          ].map((slot) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  value: slot,
                  groupValue: settings.preferredDeliverySlot,
                  onChanged: (v) => settings.updateDeliveryPreferences(slot: v),
                  title: Text(slot),
                ),
              )),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Leave at Doorstep (Zero-Contact)'),
            subtitle: const Text('Place insulated crate quietly outside door'),
            value: settings.leaveAtDoorstep,
            onChanged: (v) => settings.updateDeliveryPreferences(leaveDoor: v),
          ),
          SwitchListTile(
            title: const Text('Zero-Plastic Bio-Packaging'),
            subtitle: const Text('100% compostable cornstarch & paper bags'),
            value: settings.zeroPlasticPackaging,
            onChanged: (v) => settings.updateDeliveryPreferences(zeroPlastic: v),
          ),
          SwitchListTile(
            title: const Text('Dawn Harvest SMS Alerts'),
            value: settings.harvestSmsAlerts,
            onChanged: (v) => settings.updateDeliveryPreferences(smsAlerts: v),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
