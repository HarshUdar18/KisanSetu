import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/orders_provider.dart';

/// Implements Stitch `payment_processing`.
class PaymentProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const PaymentProcessingScreen({super.key, this.paymentData = const {}});

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1100), () async {
      if (!mounted) return;
      final orders = context.read<OrdersProvider>();
      final cart = context.read<CartProvider>();
      final orderId = widget.paymentData['orderId'] as String? ?? 'ord-2045';
      final amount = (widget.paymentData['amount'] as num?)?.toDouble() ?? 530.0;
      final method = widget.paymentData['paymentMethod'] as String? ?? 'UPI_GPAY';
      final simSuccess = widget.paymentData['simulateSuccess'] as bool? ?? true;

      final ok = await orders.processAndVerifyPayment(
        orderId: orderId,
        amount: amount,
        paymentMethod: method,
        simulateSuccess: simSuccess,
      );
      if (!mounted) return;
      if (ok) {
        await cart.clearCart();
        if (!mounted) return;
        context.go('/order-confirmed', extra: {
          'orderId': orderId,
          'amount': amount,
        });
      } else {
        context.go('/payment-failed', extra: widget.paymentData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(strokeWidth: 5),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Securing Your Fresh Morning Harvest',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifying payment with backend gateway and reserving FPO harvest crates...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
