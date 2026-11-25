import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

enum SystemStateType {
  noInternet,
  serverError,
  maintenance,
  sessionExpired,
  unauthorized,
  generalError,
}

/// Implements Stitch `no_internet_connection`, `server_error`, `maintenance_screen`,
/// and exception states (`session_expired`, `unauthorized`, `general_error`).
class SystemStateScreen extends StatelessWidget {
  final SystemStateType type;
  final String? customMessage;
  final VoidCallback? onRetry;

  const SystemStateScreen({
    super.key,
    required this.type,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final config = _configFor(type);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: config.badgeBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(config.icon, size: 48, color: config.iconColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                config.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                customMessage ?? config.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry ??
                      () {
                        if (type == SystemStateType.sessionExpired ||
                            type == SystemStateType.unauthorized) {
                          context.go('/login');
                        } else {
                          context.go('/home');
                        }
                      },
                  icon: Icon(config.ctaIcon),
                  label: Text(config.ctaLabel),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StateConfig _configFor(SystemStateType t) {
    switch (t) {
      case SystemStateType.noInternet:
        return const _StateConfig(
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.tertiary,
          badgeBg: AppColors.tertiaryFixed,
          title: 'Connection Dropped in the Fields',
          subtitle:
              'Looks like your mobile network or Wi-Fi is offline. Reconnect to sync live farm harvest rates.',
          ctaLabel: 'Retry Connection',
          ctaIcon: Icons.refresh,
        );
      case SystemStateType.serverError:
        return const _StateConfig(
          icon: Icons.cloud_off_rounded,
          iconColor: AppColors.error,
          badgeBg: AppColors.errorContainer,
          title: 'Our Harvest Servers are Overloaded',
          subtitle:
              'We are experiencing a temporary hiccup reaching our FPO dispatch servers. Please try again shortly.',
          ctaLabel: 'Retry Request',
          ctaIcon: Icons.refresh,
        );
      case SystemStateType.maintenance:
        return const _StateConfig(
          icon: Icons.engineering_rounded,
          iconColor: AppColors.primary,
          badgeBg: AppColors.secondaryContainer,
          title: 'Upgrading Farm Gate Logistics',
          subtitle:
              'Scheduled maintenance is underway to improve morning harvest routing. We will be back within 15 minutes.',
          ctaLabel: 'Check Status',
          ctaIcon: Icons.sync,
        );
      case SystemStateType.sessionExpired:
        return const _StateConfig(
          icon: Icons.lock_clock_rounded,
          iconColor: AppColors.tertiary,
          badgeBg: AppColors.tertiaryFixed,
          title: 'Session Expired',
          subtitle:
              'For your account security, please sign in again with your mobile number to continue.',
          ctaLabel: 'Sign In Again',
          ctaIcon: Icons.login,
        );
      case SystemStateType.unauthorized:
        return const _StateConfig(
          icon: Icons.gpp_maybe_rounded,
          iconColor: AppColors.error,
          badgeBg: AppColors.errorContainer,
          title: 'Unauthorized Access',
          subtitle: 'You do not have permission to view this resource. Please log in with a customer account.',
          ctaLabel: 'Go to Login',
          ctaIcon: Icons.login,
        );
      case SystemStateType.generalError:
        return const _StateConfig(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          badgeBg: AppColors.errorContainer,
          title: 'Something Went Wrong',
          subtitle: 'An unexpected error occurred while processing your request.',
          ctaLabel: 'Try Again',
          ctaIcon: Icons.refresh,
        );
    }
  }
}

class _StateConfig {
  final IconData icon;
  final Color iconColor;
  final Color badgeBg;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final IconData ctaIcon;

  const _StateConfig({
    required this.icon,
    required this.iconColor,
    required this.badgeBg,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.ctaIcon,
  });
}
