import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/mock_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../cart/providers/cart_provider.dart';

/// Implements Stitch `apply_coupon_offers`.
class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final _ctrl = TextEditingController();
  String? _feedback;
  bool _isError = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tryApply(String code) {
    final res = context.read<CartProvider>().applyCoupon(code);
    setState(() {
      _isError = res['valid'] != true;
      _feedback = res['message'] as String?;
    });
    if (!_isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_feedback ?? 'Coupon applied!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Apply Coupon & Offers'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'Enter coupon code'),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _tryApply(_ctrl.text),
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isError
                    ? AppColors.errorContainer
                    : AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                _feedback!,
                style: TextStyle(
                  color: _isError
                      ? AppColors.onErrorContainer
                      : AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Available Farmer Coupons',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          ...MockCustomerServices.coupons.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              c['code'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onTertiaryFixed,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _tryApply(c['code'] as String),
                            child: const Text('APPLY'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c['title'] as String,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 2),
                      Text(c['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
