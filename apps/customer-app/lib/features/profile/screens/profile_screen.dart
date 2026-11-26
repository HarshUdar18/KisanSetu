import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../location/providers/address_provider.dart';

/// Implements Stitch `customer_profile`.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // Customer Identity Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.level2,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Icon(Icons.person, size: 34, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isAuthenticated
                            ? (auth.fullName ?? 'Kisan Setu Customer')
                            : 'Guest Shopper',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        auth.isAuthenticated
                            ? (auth.identifier != null
                                ? '+91 ${auth.identifier}'
                                : 'Verified Customer')
                            : 'Sign in to sync baskets & orders',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.push(auth.isAuthenticated ? '/edit-profile' : '/login'),
                  icon: const Icon(Icons.edit, color: AppColors.tertiaryFixed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Wallet & Harvest Impact Row
          Row(
            children: [
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.primary),
                    title: const Text('₹420', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Kisan Wallet'),
                    onTap: () => context.push('/wallet'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.eco_outlined, color: AppColors.secondary),
                    title: const Text('₹4,280',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Farmer Impact'),
                    onTap: () => context.push('/harvest-impact'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SectionCard(
            title: 'Orders & Planning',
            items: [
              _MenuItem(Icons.autorenew, 'My Subscriptions',
                  () => context.push('/subscriptions')),
              _MenuItem(Icons.location_on_outlined, 'Saved Addresses',
                  () => context.push('/addresses')),
              _MenuItem(Icons.schedule, 'Delivery & Harvest Preferences',
                  () => context.push('/delivery-preferences')),
              _MenuItem(Icons.agriculture_outlined, 'Weekend Farm Visits & Workshops',
                  () => context.push('/farm-visits')),
            ],
          ),
          const SizedBox(height: 12),

          _SectionCard(
            title: 'App & Account Settings',
            items: [
              _MenuItem(Icons.notifications_outlined, 'Notifications & Alerts',
                  () => context.push('/notifications')),
              _MenuItem(Icons.translate, 'Language (${settings.languageCode.toUpperCase()})',
                  () => context.push('/select-language', extra: true)),
              _MenuItem(
                Icons.dark_mode_outlined,
                'Appearance (${settings.themeMode.name.toUpperCase()})',
                () {
                  final next = settings.themeMode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                  settings.setThemeMode(next);
                },
              ),
              _MenuItem(Icons.security_outlined, 'Account Security & Sessions',
                  () => context.push('/account-security')),
              _MenuItem(Icons.help_outline, 'Help, FAQ & Support',
                  () => context.push('/support')),
            ],
          ),
          const SizedBox(height: 16),

          if (auth.isAuthenticated)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                final ok = await ConfirmationDialog.show(
                  context,
                  title: 'Logout from Kisan Setu?',
                  message: 'You can sign back in anytime using your mobile number.',
                  confirmLabel: 'Logout',
                  isDestructive: true,
                );
                if (ok == true && context.mounted) {
                  await auth.logout();
                  if (!context.mounted) return;
                  context.read<AddressProvider>().clearLocalState();
                  context.read<CartProvider>().clearLocalState();
                  await settings.clearLocationOnLogout();
                  if (!context.mounted) return;
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            )
          else
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Continue with Mobile Number'),
            ),

          const SizedBox(height: 12),
          Center(
            child: Text(
              '${AppConstants.appName} ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.outline,
                  ),
            ),
          ),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon, color: AppColors.primary, size: 22),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.label, this.onTap);
}
