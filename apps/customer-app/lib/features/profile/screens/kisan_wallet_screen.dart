import 'package:flutter/material.dart';
import '../../../core/services/mock_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `kisan_wallet_passbook`.
class KisanWalletScreen extends StatelessWidget {
  const KisanWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Kisan Passbook Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AVAILABLE WALLET BALANCE',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryFixed,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('₹420.00',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Instant refunds & glass-bottle deposit credits',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Recent Transactions',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.add_circle_outline, color: AppColors.success),
              title: Text('Glass Bottle Return Credit'),
              subtitle: Text('22 Nov 2026 • Bhor Dairy Hub'),
              trailing: Text('+₹60',
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.remove_circle_outline, color: AppColors.outline),
              title: Text('Applied to Order #KS-1988'),
              subtitle: Text('19 Nov 2026'),
              trailing: Text('-₹140', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Implements Stitch `harvest_impact_payout_ledger`.
class HarvestImpactScreen extends StatelessWidget {
  const HarvestImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Harvest Impact & Payout Ledger'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIRECT FARMER PAYOUTS GENERATED',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryFixed,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('₹4,280.00',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('Across 14 baskets • 6 verified FPO collectives',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...MockCustomerServices.farmers.map((f) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.agriculture,
                        color: AppColors.onSecondaryContainer),
                  ),
                  title: Text(f['name'] as String),
                  subtitle: Text('${f['farmerName']} • ${f['cluster']}'),
                  trailing: const Text('80% Direct',
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              )),
        ],
      ),
    );
  }
}

/// Implements Stitch `seasonal_farm_visit_workshop`.
class FarmVisitScreen extends StatefulWidget {
  const FarmVisitScreen({super.key});

  @override
  State<FarmVisitScreen> createState() => _FarmVisitScreenState();
}

class _FarmVisitScreenState extends State<FarmVisitScreen> {
  final Set<String> _booked = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Seasonal Farm Visits'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Connect with the Soil: Weekend Farm Trails',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...MockCustomerServices.farmVisits.map((v) {
            final isBooked = _booked.contains(v['id']);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v['title'] as String,
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text('${v['date']}\n${v['location']}'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${(v['price'] as num).toStringAsFixed(0)} / person',
                            style: Theme.of(context).textTheme.labelLarge),
                        ElevatedButton(
                          onPressed: isBooked
                              ? null
                              : () => setState(() => _booked.add(v['id'] as String)),
                          child: Text(isBooked ? 'Seat Reserved' : 'Book Trail'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
