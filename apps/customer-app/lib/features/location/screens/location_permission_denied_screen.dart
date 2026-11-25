import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `location_permission_denied_settings_guidance`.
class LocationPermissionDeniedScreen extends StatelessWidget {
  final bool isPermanentlyDenied;

  const LocationPermissionDeniedScreen({
    super.key,
    this.isPermanentlyDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Delivery Location'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: AppColors.error, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Access is Turned Off',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.onErrorContainer,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You can still browse all fresh farm produce or enter your PIN code manually.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onErrorContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'How to Enable in Android Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Column(
                  children: [
                    _StepRow(step: '1', text: 'Open Device Settings > Apps > Kisan Setu'),
                    Divider(height: 20),
                    _StepRow(step: '2', text: 'Tap Permissions > Location'),
                    Divider(height: 20),
                    _StepRow(step: '3', text: 'Select "Allow only while using the app"'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/select-location'),
                  icon: const Icon(Icons.search),
                  label: const Text('Enter PIN Code / Address Manually'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continue Browsing Catalog'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String step;
  final String text;

  const _StepRow({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            step,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
