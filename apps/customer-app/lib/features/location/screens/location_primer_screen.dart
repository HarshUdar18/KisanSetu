import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `why_kisan_setu_needs_location` (Contextual Permission Primer).
class LocationPrimerScreen extends StatelessWidget {
  const LocationPrimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Delivery Location'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Check Farm-to-Home Delivery in Your Area',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kisan Setu routes dawn-harvested produce from nearby FPO hubs directly to your neighborhood. Location access helps us:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _ReasonTile(
                icon: Icons.verified_outlined,
                title: 'Verify Serviceable Delivery Zones',
                subtitle: 'Confirm cold-chain morning delivery availability for your PIN code.',
              ),
              const SizedBox(height: 12),
              const _ReasonTile(
                icon: Icons.agriculture_outlined,
                title: 'Match Nearest FPO Clusters',
                subtitle: 'Show fresh harvest from farms closest to your home.',
              ),
              const SizedBox(height: 12),
              const _ReasonTile(
                icon: Icons.lock_outline,
                title: 'Your Privacy Stays Protected',
                subtitle: 'GPS is only used to suggest your address; you always confirm before ordering.',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    settings.setLocationPermission(PermissionStatusState.granted);
                    context.push('/serviceability-check', extra: {'pinCode': settings.selectedLocationPin});
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Allow Location Access'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/select-location'),
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('Select Location Manually'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    settings.setLocationPermission(PermissionStatusState.denied);
                    context.push('/location-permission-denied');
                  },
                  child: const Text('Not Now / Permission Denied'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReasonTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceContainer,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
