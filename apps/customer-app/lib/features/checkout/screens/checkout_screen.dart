import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../cart/providers/cart_provider.dart';
import '../../location/providers/address_provider.dart';
import '../../orders/providers/orders_provider.dart';

/// Implements Stitch `checkout_flow`.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryDate = 'Tomorrow, 25 Nov';
  String _slot = '6:00 AM - 8:00 AM';
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addr = context.watch<AddressProvider>().defaultAddress;
    final cartProvider = context.watch<CartProvider>();
    final orders = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Checkout Summary'),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.margin),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: AppShadows.level3,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FINAL PAYABLE',
                      style: TextStyle(fontSize: 10, color: AppColors.outline)),
                  Text(
                    '₹${cartProvider.finalPayable.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: orders.isLoading
                      ? null
                      : () async {
                          final order = await orders.checkout(
                            addressId: addr?.id ?? 'addr-1',
                            deliveryDate: _deliveryDate,
                            deliverySlot: _slot,
                            cart: cartProvider.cart,
                            notes: _notesCtrl.text.trim(),
                          );
                          if (!context.mounted || order == null) return;
                          context.push('/payment', extra: {
                            'orderId': order.id,
                            'orderNumber': order.orderNumber,
                            'amount': cartProvider.finalPayable,
                          });
                        },
                  child: const Text('Proceed to Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Delivery Address', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: Text(addr != null ? '${addr.label} • ${addr.pincode}' : 'Select Address'),
              subtitle: Text(addr?.fullAddress ?? 'Kothrud, Pune 411038'),
              trailing: TextButton(
                onPressed: () => context.push('/addresses'),
                child: const Text('Change'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Select Delivery Date', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Tomorrow, 25 Nov', 'Day After, 26 Nov'].map((d) {
              return ChoiceChip(
                label: Text(d),
                selected: _deliveryDate == d,
                onSelected: (_) => setState(() => _deliveryDate = d),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Select Delivery Time Slot',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['6:00 AM - 8:00 AM', '8:00 AM - 10:00 AM', '5:00 PM - 7:00 PM']
                .map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: _slot == s,
                onSelected: (_) => setState(() => _slot = s),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Delivery Instructions (Optional)',
              hintText: 'e.g. Ring bell once, leave near shoe rack',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_offer_outlined, color: AppColors.tertiary),
              title: Text(cartProvider.appliedCouponCode ?? 'Apply Coupon & Offers'),
              subtitle: Text(cartProvider.couponDiscount > 0
                  ? 'Saved ₹${cartProvider.couponDiscount.toStringAsFixed(0)}'
                  : 'Tap to view available farmer coupons'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/apply-coupon'),
            ),
          ),
        ],
      ),
    );
  }
}
