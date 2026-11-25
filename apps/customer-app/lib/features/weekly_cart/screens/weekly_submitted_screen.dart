import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/weekly_cart_provider.dart';

/// Implements Stitch `weekly_cart_submitted_edit_limit`.
class WeeklySubmittedScreen extends StatelessWidget {
  const WeeklySubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeeklyCartProvider>();
    final cart = provider.activeWeeklyCart;
    final isLocked = cart?.status == 'LOCKED' || (cart?.modificationCount ?? 0) >= 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Weekly Cart Status'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.tertiaryFixed.withValues(alpha: 0.45)
                    : AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline : Icons.check_circle,
                    size: 36,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocked
                              ? 'Weekly Cart Locked (Edit Limit Reached)'
                              : 'Weekly Cart Submitted for ${cart?.title ?? 'Week 44'}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocked
                              ? 'You have used your 1 allowed correction. Farmer harvest quantities are now finalized.'
                              : 'You can modify this submitted weekly cart 1 time before dispatch cutoff.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status'),
                        Text(cart?.status ?? 'SUBMITTED',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Corrections Used'),
                        Text('${cart?.modificationCount ?? 0} / 1',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Weekly Total'),
                        Text(
                          '₹${cart?.weeklyEstimatedTotal.toStringAsFixed(0) ?? '0'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (!isLocked)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ConfirmationDialog.show(
                      context,
                      title: 'Use Your 1 Correction?',
                      message:
                          'Modifying a submitted weekly cart uses your single allowed edit and locks further changes.',
                      confirmLabel: 'Confirm & Lock Edit',
                    );
                    if (ok == true && context.mounted) {
                      await provider.modifySubmittedWeeklyCart();
                    }
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Use 1-Time Correction Edit'),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
