import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `account_security` (Password, Biometrics, Active Sessions).
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _biometrics = true;
  final List<Map<String, String>> _sessions = [
    {'device': 'Pixel 8 Pro (This Device)', 'loc': 'Pune, IN • Active now'},
    {'device': 'Chrome Web (Desktop)', 'loc': 'Pune, IN • 2 days ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Account Security'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Biometrics & App Passcode'),
              subtitle: const Text('Require fingerprint/PIN before UPI checkout'),
              value: _biometrics,
              onChanged: (v) => setState(() => _biometrics = v),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset, color: AppColors.primary),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/forgot-password'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Active Sessions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ..._sessions.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.devices, color: AppColors.primary),
                  title: Text(s['device']!),
                  subtitle: Text(s['loc']!),
                ),
              )),
          if (_sessions.length > 1)
            OutlinedButton(
              onPressed: () async {
                final ok = await ConfirmationDialog.show(
                  context,
                  title: 'Logout Other Devices?',
                  message: 'All other signed-in devices will be disconnected.',
                  confirmLabel: 'Logout Others',
                );
                if (ok == true) {
                  setState(() => _sessions.removeRange(1, _sessions.length));
                }
              },
              child: const Text('Logout Other Devices'),
            ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: () => context.push('/delete-account'),
            icon: const Icon(Icons.delete_forever, color: AppColors.error),
            label: const Text('Delete Account Request',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
