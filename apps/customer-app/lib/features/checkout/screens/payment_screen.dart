import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `select_payment_method_upi`.
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;

  const PaymentScreen({super.key, this.checkoutData = const {}});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'UPI_GPAY';

  @override
  Widget build(BuildContext context) {
    final amount = (widget.checkoutData['amount'] as num?)?.toDouble() ?? 530.0;
    final orderId = widget.checkoutData['orderId'] as String? ?? 'ord-2045';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Select Payment Method'),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.margin),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: AppShadows.level3,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/payment-processing',
                      extra: {
                        'orderId': orderId,
                        'amount': amount,
                        'paymentMethod': _method,
                        'simulateSuccess': true,
                      },
                    );
                  },
                  child: Text('Pay ₹${amount.toStringAsFixed(0)} Securely'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  context.push(
                    '/payment-processing',
                    extra: {
                      'orderId': orderId,
                      'amount': amount,
                      'paymentMethod': _method,
                      'simulateSuccess': false,
                    },
                  );
                },
                child: const Text('Simulate Payment Failure (Dev Test)'),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount to Pay'),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Recommended Fast UPI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ...[
            {
              'id': 'UPI_GPAY',
              'title': 'Google Pay (UPI)',
              'sub': 'Instant 1-tap settlement',
            },
            {
              'id': 'UPI_PHONEPE',
              'title': 'PhonePe UPI',
              'sub': 'Zero convenience fee',
            },
            {
              'id': 'UPI_ID',
              'title': 'Enter Any UPI ID',
              'sub': 'BHIM, Paytm, Cred',
            },
            {
              'id': 'CARD',
              'title': 'Credit / Debit Card',
              'sub': 'Visa, Mastercard, RuPay',
            },
            {
              'id': 'COD',
              'title': 'Cash / UPI on Delivery',
              'sub': 'Pay at doorstep',
            },
          ].map(
            (m) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: RadioListTile<String>(
                value: m['id']!,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
                title: Text(
                  m['title']!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Text(m['sub']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
