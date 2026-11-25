import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/mock_farmer_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../providers/demand_provider.dart';

/// Implements Stitch `market_demand_orders` (separating Demand Opportunities vs Confirmed Orders).
class MarketDemandScreen extends StatefulWidget {
  const MarketDemandScreen({super.key});

  @override
  State<MarketDemandScreen> createState() => _MarketDemandScreenState();
}

class _MarketDemandScreenState extends State<MarketDemandScreen> {
  int _tab = 0; // 0: Demand Requests, 1: Confirmed Orders

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DemandProvider>();
    final demands = provider.demands;
    final orders = provider.orders;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Demand & Orders',
                  style: Theme.of(context).textTheme.headlineMedium),
              TextButton.icon(
                onPressed: () => context.push('/mandi-rates'),
                icon: const Icon(Icons.show_chart, size: 18),
                label: const Text('Mandi Ticker'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                  value: 0, label: Text('Buyer Demand (${demands.length})')),
              ButtonSegment(
                  value: 1, label: Text('Confirmed Orders (${orders.length})')),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(height: 14),
          if (_tab == 0)
            ...demands.map((d) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(d['buyer'] as String,
                                  style: Theme.of(context).textTheme.labelLarge),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: d['status'] == 'ACCEPTED'
                                    ? AppColors.secondaryContainer
                                    : AppColors.tertiaryFixed,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                d['status'] as String,
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                            '${d['crop']} • ₹${(d['rate'] as num).toStringAsFixed(0)}/kg (Est. ₹${(d['total'] as num).toStringAsFixed(0)})'),
                        Text('${d['window']} • ${d['pickup']}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 10),
                        if (d['status'] == 'OPEN')
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => provider.respondToDemand(
                                    d['id'] as String, 'REJECTED'),
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () =>
                                    context.push('/demand/escrow/${d['id']}'),
                                child: const Text('Escrow Terms'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => provider.respondToDemand(
                                    d['id'] as String, 'ACCEPTED'),
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ))
          else
            ...orders.map((o) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(o['buyer'] as String),
                    subtitle: Text(
                        '${o['items']}\n${o['slot']} • Status: ${o['status']}'),
                    isThreeLine: true,
                    trailing: Text(
                      '₹${(o['amount'] as num).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onTap: () => context.push('/collection/handover'),
                  ),
                )),
        ],
      ),
    );
  }
}

/// Implements Stitch `bulk_escrow_agreement_dispatch`.
class BulkEscrowScreen extends StatelessWidget {
  final String demandId;

  const BulkEscrowScreen({super.key, required this.demandId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Bulk Escrow Agreement'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Escrow-Protected Contract #$demandId',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Buyer funds are pre-locked in the Kisan Setu RBI Escrow Pool prior to dawn harvest dispatch. Payout releases automatically on Friday DBT cycle after APMC QC check.',
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<DemandProvider>()
                      .respondToDemand(demandId, 'ACCEPTED');
                  context.pop();
                },
                child: const Text('Sign & Accept Escrow Agreement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Implements Stitch `daily_apmc_mandi_rates_live_spot_ticker`.
class MandiSpotRatesScreen extends StatelessWidget {
  const MandiSpotRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: FarmerStackAppBar(
        title: 'Daily APMC Mandi Spot Rates',
        actions: [
          TextButton(
            onPressed: () => context.push('/mandi-compare'),
            child: const Text('Compare'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.margin),
        itemCount: MockFarmerServices.mandiSpotRates.length,
        itemBuilder: (_, i) {
          final r = MockFarmerServices.mandiSpotRates[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(r['crop'] as String),
              subtitle: Text(r['mandi'] as String),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${(r['rate'] as num).toStringAsFixed(0)}/${r['unit']}',
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(r['trend'] as String,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Implements Stitch `multi_mandi_price_comparison_distance_matrix`.
class MandiCompareScreen extends StatelessWidget {
  const MandiCompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Multi-Mandi Price Comparison'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Mulshi FPO Direct Hub (4.2 km)'),
              subtitle: Text('Net Realization: ₹38/kg • Zero Commission'),
              trailing: Chip(label: Text('Best Net')),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Pune Gultekdi APMC (24 km)'),
              subtitle: Text('Gross ₹35/kg • Transport & Hammali -₹4/kg'),
              trailing: Text('₹31/kg Net'),
            ),
          ),
        ],
      ),
    );
  }
}
