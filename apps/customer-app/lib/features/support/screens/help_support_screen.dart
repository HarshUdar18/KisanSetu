import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `help_support_center` + Terms, Privacy, About & Version.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Help & Support Center'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Need help with today's harvest?",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Our Pune FPO support desk is live 6:00 AM – 10:00 PM daily.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.harvestGold,
                    foregroundColor: AppColors.onTertiaryFixed,
                  ),
                  onPressed: () => context.push('/support-chat'),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Start Live Farm Support Chat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.quiz_outlined, color: AppColors.primary),
                  title: const Text('FAQs & Sourcing Knowledge Base'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/faq'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined,
                      color: AppColors.primary),
                  title: const Text('Raise an Issue / Report Problem'),
                  subtitle: const Text('Order, Payment, or Delivery issues'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/raise-ticket'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms and Conditions'),
                  onTap: () => _showInfoDialog(
                    context,
                    'Terms and Conditions',
                    'Kisan Setu connects consumers directly with verified FPOs. Weekly carts can be corrected once before the 9:00 PM harvest cutoff.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  onTap: () => _showInfoDialog(
                    context,
                    'Privacy Policy',
                    'Your location and delivery details are used strictly to verify serviceable corridors and fulfill morning farm deliveries.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Kisan Setu'),
                  subtitle: const Text(AppConstants.appVersion),
                  onTap: () => _showInfoDialog(
                    context,
                    'About Kisan Setu',
                    '${AppConstants.appName} ${AppConstants.appVersion}\nDirect Farm-to-Kitchen agricultural marketplace empowering 50,000+ farmers.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
