import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/cart_provider.dart';

/// Implements Stitch `shopping_cart` and `empty_cart`.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final cart = cartProvider.cart;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Farm Basket'),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
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
                        const Text(
                          'TOTAL BILL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          '₹${cartProvider.finalPayable.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/checkout'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: cart.items.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_basket_outlined,
              title: 'Fresh fields await!',
              subtitle:
                  'Your farm basket is empty. Add dawn-harvested vegetables, A2 milk, or heirloom grains.',
              actionLabel: 'Browse Fresh Harvest',
              onAction: () => context.go('/home'),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.margin),
              children: [
                if (cart.subtotal >= 299)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping,
                            color: AppColors.onSecondaryContainer),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FREE DELIVERY UNLOCKED!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                              Text(
                                'Sourced fresh from Mulshi & Baramati clusters',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: const Text('FULFILLMENT SLOT',
                        style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    subtitle: Text(
                        '${settings.selectedLocationName} • Tomorrow 6:30 AM'),
                    trailing: TextButton(
                      onPressed: () => context.push('/select-location'),
                      child: const Text('Change'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Farm Basket (${cart.itemCount} items)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text(
                      '100% Traceable',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...cart.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(Icons.eco, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: Theme.of(context).textTheme.labelLarge),
                                  Text(
                                    '${item.unit} • ₹${item.unitPrice.toStringAsFixed(0)}/${item.unit}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (item.quantity <= 1) {
                                            final ok = await ConfirmationDialog.show(
                                              context,
                                              title: 'Remove Item?',
                                              message:
                                                  'Remove ${item.productName} from your Farm Basket?',
                                              confirmLabel: 'Remove',
                                              isDestructive: true,
                                            );
                                            if (ok == true) {
                                              cartProvider.removeItem(item.id);
                                            }
                                          } else {
                                            cartProvider.updateQuantity(
                                                item.id, item.quantity - 1);
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          item.quantity.toStringAsFixed(0),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => cartProvider.updateQuantity(
                                            item.id, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),

                // Coupon Banner
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_offer_outlined,
                        color: AppColors.tertiary),
                    title: Text(
                      cartProvider.appliedCouponCode != null
                          ? '${cartProvider.appliedCouponCode} APPLIED'
                          : 'Apply Farmer Coupon & Offers',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    subtitle: Text(
                      cartProvider.appliedCouponCode != null
                          ? '₹${cartProvider.couponDiscount.toStringAsFixed(0)} saved on your basket'
                          : 'Try KISANFIRST for ₹50 off',
                    ),
                    trailing: cartProvider.appliedCouponCode != null
                        ? TextButton(
                            onPressed: cartProvider.removeCoupon,
                            child: const Text('Remove'),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: () => context.push('/apply-coupon'),
                  ),
                ),
                const SizedBox(height: 12),

                // Direct Fair Share Impact Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Direct Fair Share Impact',
                              style: Theme.of(context).textTheme.labelLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: const Text(
                              '80% Farmer Share',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${cartProvider.directFarmerShare.toStringAsFixed(0)} goes straight to the collective bank accounts of FPO producer groups without middleman cuts.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: const LinearProgressIndicator(
                          value: 0.80,
                          minHeight: 8,
                          backgroundColor: AppColors.tertiaryFixed,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bill Breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bill Breakdown',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        _BillRow('Item Total (${cart.itemCount} items)',
                            '₹${cart.subtotal.toStringAsFixed(0)}'),
                        _BillRow('Direct Farmer Contribution',
                            '₹${cartProvider.directFarmerShare.toStringAsFixed(0)}'),
                        _BillRow(
                            'Delivery Partner Fee',
                            cart.deliveryFee == 0
                                ? 'FREE'
                                : '₹${cart.deliveryFee.toStringAsFixed(0)}'),
                        _BillRow('Handling & Bio-Packaging',
                            '₹${cart.logisticsFee.toStringAsFixed(0)}'),
                        if (cartProvider.couponDiscount > 0)
                          _BillRow(
                            'Coupon Discount (${cartProvider.appliedCouponCode})',
                            '-₹${cartProvider.couponDiscount.toStringAsFixed(0)}',
                            highlight: true,
                          ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('To Pay',
                                style: Theme.of(context).textTheme.headlineSmall),
                            Text(
                              '₹${cartProvider.finalPayable.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _BillRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: highlight ? AppColors.primary : AppColors.onSurfaceVariant,
                  )),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: highlight ? AppColors.primary : AppColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
