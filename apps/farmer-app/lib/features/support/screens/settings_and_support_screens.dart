import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

class FarmerSettingsScreen extends StatelessWidget {
  const FarmerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer Settings'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text('Language (${s.languageCode.toUpperCase()})'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/select-language', extra: true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification Preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/notification-preferences'),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: s.themeMode == ThemeMode.dark,
                  onChanged: (v) =>
                      s.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `farmer_helpdesk_ticket_redressal_taluka_csc_centers`.
class FarmerSupportScreen extends StatelessWidget {
  const FarmerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer Helpdesk & Taluka CSC'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toll-Free Kisan Helpline',
                    style: TextStyle(color: AppColors.tertiaryFixed, fontSize: 11)),
                SizedBox(height: 4),
                Text('1800-267-1199 (7 AM – 9 PM)',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text('Mulshi Taluka CSC & FPO Redressal Desk',
                    style: TextStyle(color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined, color: AppColors.primary),
              title: const Text('Success Stories & Farmer Knowledge Hub'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/knowledge-hub'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('${AppConstants.appName} ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class KnowledgeHubScreen extends StatelessWidget {
  const KnowledgeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmer Knowledge Hub'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('कृषी ज्ञान भांडार • Drip Fertigation Guide'),
              subtitle: Text('How Mulshi FPO farmers increased Spinach yield by 28%'),
            ),
          ),
        ],
      ),
    );
  }
}
