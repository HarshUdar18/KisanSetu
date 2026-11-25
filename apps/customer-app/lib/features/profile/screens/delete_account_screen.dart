import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';

/// Implements Stitch `delete_account_confirmation`.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmed = false;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Delete Account'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: _submitted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Deletion Request Scheduled',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Your account deletion request has been logged and will complete within 7 days unless cancelled by logging back in.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/welcome'),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Text(
                      'Delete Kisan Setu Account?\nAll active subscriptions, weekly carts, and wallet balances will be permanently closed.',
                      style: TextStyle(color: AppColors.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _confirmed,
                    onChanged: (v) => setState(() => _confirmed = v ?? false),
                    title: const Text(
                        'I understand this action cannot be undone after 7 days.'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: _confirmed
                          ? () async {
                              await context.read<AuthProvider>().logout();
                              if (mounted) setState(() => _submitted = true);
                            }
                          : null,
                      child: const Text('Confirm Account Deletion'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
