import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `payment_failed_retry`.
class PaymentFailedScreen extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const PaymentFailedScreen({super.key, this.paymentData = const {}});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Payment Failed'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 52, color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Payment Could Not Be Verified',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'No amount was debited. Your farm basket items are still reserved—choose a fast recovery option below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/payment', extra: paymentData),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Payment / Choose Another UPI'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/cart'),
                child: const Text('Return to Farm Basket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
