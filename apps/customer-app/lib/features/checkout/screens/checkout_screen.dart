import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_gate.dart';
import '../../../core/widgets/kisan_header.dart';
import '../../auth/providers/auth_provider.dart';
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
  String _deliveryDate = 'Tomorrow';
  String _slot = '';
  List<Map<String, dynamic>> _slots = const [];
  bool _loadingSlots = true;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSlots);
  }

  Future<void> _loadSlots() async {
    try {
      final res = await context
          .read<AddressProvider>()
          .dioClient
          .get('/delivery-slots', queryParameters: {'slotType': 'FASTEST_DELIVERY'});
      final raw = (res.data['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (mounted) {
        setState(() {
          _slots = raw;
          if (raw.isNotEmpty) _slot = raw.first['label'] as String? ?? '';
          _loadingSlots = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        appBar: KisanStackAppBar(title: 'Checkout Summary'),
        body: GuestAuthRequiredView(
          icon: Icons.shopping_bag_outlined,
          title: 'Sign in to complete checkout',
          subtitle:
              'Verify your mobile number and select a delivery address to place your order.',
        ),
      );
    }

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
                          if (addr == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a delivery address first.'),
                              ),
                            );
                            context.push('/select-location');
                            return;
                          }
                          if (addr.latitude != null && addr.longitude != null) {
                            try {
                              final repo = LocationRepository(
                                dioClient: context.read<AddressProvider>().dioClient,
                              );
                              final check = await repo.validateServiceArea(
                                addr.latitude!,
                                addr.longitude!,
                                requestedOperation: 'CUSTOMER_DELIVERY',
                                pinCode: addr.pincode,
                                locality: addr.locationSummary,
                                city: addr.city,
                                state: addr.state,
                                addressId: addr.id,
                              );
                              if (!context.mounted) return;
                              if (!check.serviceable) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(check.customerFriendlyMessage)),
                                );
                                return;
                              }
                            } catch (_) {
                              // Backend createOrderFromCart also performs authoritative validation
                            }
                          } else {
                            final pinCheck = await context
                                .read<AddressProvider>()
                                .checkServiceability(addr.pincode);
                            if (!context.mounted) return;
                            if (!pinCheck.isServiceable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    pinCheck.message ??
                                        'Delivery is not currently available at this address.',
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          final order = await orders.checkout(
                            addressId: addr.id,
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
              title: Text(addr != null
                  ? '${addr.label} • ${addr.pincode}'
                  : 'Delivery address not selected'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addr?.fullAddress ??
                      'Select or add a delivery address before placing your order'),
                  if (addr != null && addr.recipientFullName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Contact: ${addr.recipientFullName}'
                      '${addr.recipientPhone != null && addr.recipientPhone!.isNotEmpty ? ' • ${addr.recipientPhone}' : ''}'
                      '${addr.recipientType == 'SOMEONE_ELSE' ? ' (Recipient)' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
              trailing: TextButton(
                onPressed: () =>
                    context.push(addr != null ? '/addresses' : '/map-location'),
                child: Text(addr != null ? 'Change' : 'Add'),
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
          if (_loadingSlots)
            const LinearProgressIndicator()
          else if (_slots.isEmpty)
            const Text('No active delivery slots available right now.')
          else
            Wrap(
              spacing: 8,
              children: _slots.map((s) {
                final label = s['label'] as String? ?? '';
                return ChoiceChip(
                  label: Text(label),
                  selected: _slot == label,
                  onSelected: (_) => setState(() => _slot = label),
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
