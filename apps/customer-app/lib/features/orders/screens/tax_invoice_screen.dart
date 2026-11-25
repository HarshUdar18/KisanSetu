import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/orders_provider.dart';

/// Implements Stitch `tax_invoice_harvest_certificate`.
class TaxInvoiceScreen extends StatelessWidget {
  final String orderId;

  const TaxInvoiceScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrdersProvider>().getById(orderId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Tax Invoice & Harvest Certificate'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax Invoice & Traceability',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Icon(Icons.verified, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Order: #${order?.orderNumber ?? orderId}'),
                  Text('Date: ${order?.deliveryDate ?? '25 Nov 2026'}'),
                  const Text('FPO Origin: Niphad & Baramati Collectives'),
                  const Divider(height: 24),
                  ...(order?.items ?? []).map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    '${i.productName} (${i.quantity.toStringAsFixed(0)} ${i.unit})')),
                            Text('₹${i.totalPrice.toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid (Incl. Agri Cess)',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        '₹${order?.totalAmount.toStringAsFixed(0) ?? '530'}',
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
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Harvest Certificate & PDF Invoice saved to Downloads.')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF Invoice'),
          ),
        ],
      ),
    );
  }
}
