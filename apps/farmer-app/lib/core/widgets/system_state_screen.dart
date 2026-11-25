import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/farmer_settings_provider.dart';
import '../theme/app_theme.dart';

enum FarmerSystemStateType {
  noInternet,
  serverError,
  maintenance,
  sessionExpired,
  unauthorized,
  kycRestricted,
}

/// Implements Stitch `offline_mode_local_sync_vault` & Module 19 exception states.
class OfflineSyncVaultScreen extends StatelessWidget {
  const OfflineSyncVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.tertiaryFixed,
                child: Icon(Icons.cloud_off, size: 48, color: AppColors.tertiary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'काळजी नको! काम चालू ठेवा.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'No worries! Keep logging harvests offline. ${settings.pendingOfflineActions} pending actions in your Local Sync Vault.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    settings.syncOfflineQueue();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline vault synced to FPO Hub!')),
                    );
                    context.go('/dashboard');
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Local Vault Now'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Continue Offline on Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FarmerSystemStateScreen extends StatelessWidget {
  final FarmerSystemStateType type;

  const FarmerSystemStateScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isKyc = type == FarmerSystemStateType.kycRestricted;
    final isSession = type == FarmerSystemStateType.sessionExpired;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor:
                    isKyc ? AppColors.tertiaryFixed : AppColors.errorContainer,
                child: Icon(
                  isKyc
                      ? Icons.verified_user_outlined
                      : isSession
                          ? Icons.lock_clock_outlined
                          : Icons.cloud_off_rounded,
                  size: 48,
                  color: isKyc ? AppColors.tertiary : AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isKyc
                    ? 'KYC Verification Required'
                    : isSession
                        ? 'Farmer Session Expired'
                        : type == FarmerSystemStateType.maintenance
                            ? 'Scheduled Hub Maintenance'
                            : 'Temporary Server Connection Issue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isKyc
                    ? 'Complete your Aadhaar & Bank DBT verification to publish produce lots and receive weekly payouts.'
                    : 'Please sign in again or retry once network connectivity stabilizes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isKyc) {
                      context.go('/kyc');
                    } else if (isSession) {
                      context.go('/login');
                    } else {
                      context.go('/dashboard');
                    }
                  },
                  child: Text(isKyc
                      ? 'Complete Farmer KYC'
                      : isSession
                          ? 'Sign In Again'
                          : 'Retry & Go to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
