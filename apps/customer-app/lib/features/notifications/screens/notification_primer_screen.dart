import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `notification_permission_primer` & `notification_settings_guidance`.
class NotificationPrimerScreen extends StatelessWidget {
  const NotificationPrimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDenied =
        settings.notificationPermission == PermissionStatusState.denied ||
            settings.notificationPermission ==
                PermissionStatusState.permanentlyDenied;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Harvest Notifications'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor:
                  isDenied ? AppColors.errorContainer : AppColors.surfaceContainer,
              child: Icon(
                isDenied
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_active_outlined,
                size: 48,
                color: isDenied ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isDenied
                  ? 'Notifications Are Currently Turned Off'
                  : 'Stay Updated on Your Morning Harvest',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isDenied
                  ? 'Enable notifications in Android Settings > Apps > Kisan Setu > Notifications to receive dawn delivery alerts.'
                  : 'Get instant alerts when your farmer packs your produce, when your EV rider arrives, and before weekly cart cutoffs.',
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
                  settings.setNotificationPermission(PermissionStatusState.granted);
                  context.pushReplacement('/notifications');
                },
                child: Text(isDenied ? 'Simulate Enable in Settings' : 'Allow Notifications'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                settings.setNotificationPermission(PermissionStatusState.denied);
              },
              child: const Text('Not Now'),
            ),
          ],
        ),
      ),
    );
  }
}
