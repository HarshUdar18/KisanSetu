import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Implements Stitch `order_confirmation_details`.
class OrderConfirmedScreen extends StatelessWidget {
  final Map<String, dynamic> confirmationData;

  const OrderConfirmedScreen({super.key, this.confirmationData = const {}});

  @override
  Widget build(BuildContext context) {
    final orderId = confirmationData['orderId'] as String? ?? 'ord-2041';
    final amount = (confirmationData['amount'] as num?)?.toDouble() ?? 530.0;

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
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Order Confirmed & Harvest Reserved!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your FPO farmers have received your dawn harvest request. Paid ₹${amount.toStringAsFixed(0)} via verified UPI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Reference'),
                          Text(orderId,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const Divider(height: 18),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimated Delivery'),
                          Text('Tomorrow, 6:30 AM',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/tracking/$orderId'),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Track 9-Stage Supply Chain'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
