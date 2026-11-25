import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../demand/providers/demand_provider.dart';
import '../../produce/providers/produce_provider.dart';
import '../../settlements/providers/settlements_provider.dart';

/// Implements Stitch `farmer_dashboard`.
class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<FarmerAuthProvider>();
    final settings = context.watch<FarmerSettingsProvider>();
    final produce = context.watch<ProduceProvider>();
    final demand = context.watch<DemandProvider>();
    final settlements = context.watch<SettlementsProvider>();
    final openDemand =
        demand.demands.where((d) => d['status'] == 'OPEN').toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerTabHeader(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        children: [
          // Micro-climate weather pill
          InkWell(
            onTap: () => context.push('/weather'),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.thermostat, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      '21°C • Mild dew at 4:00 AM • Ideal leaf moisture',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      '● Optimal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Farmer Identity Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, ${auth.fullName ?? 'Ramesh Shinde'}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '${settings.village} Organic FPO Cluster',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => context.push('/kyc/certificate'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'KYC ${auth.kycStatus.name.toUpperCase()} (Grade A Smallholder)',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Harvest Cutoff Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.level2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HARVEST CUTOFF',
                            style: TextStyle(
                                color: AppColors.onPrimaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                        Text('11:00 PM Tonight',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Column(
                        children: [
                          Text('Time Left',
                              style: TextStyle(
                                  color: AppColors.onPrimaryContainer,
                                  fontSize: 10)),
                          Text('05:42:06',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${produce.listings.length} Lots booked for tomorrow dawn dispatch',
                  style: const TextStyle(
                      color: AppColors.onPrimaryContainer, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: const LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 6,
                    backgroundColor: AppColors.primaryContainer,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.secondaryContainer),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Crates sanitized: 18/25',
                        style: TextStyle(
                            color: AppColors.onPrimaryContainer, fontSize: 11)),
                    Text('72% Pack-ready',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Produce Allocation & Quality KPIs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Produce Allocation & Quality',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Text('Live mandi sync',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _KpiCard(
                label: 'Listed',
                value: '${produce.totalActiveKg.toStringAsFixed(0)} kg',
                sub: '₹${produce.totalEstimatedValue.toStringAsFixed(0)} est.',
              ),
              const SizedBox(width: 8),
              const _KpiCard(
                label: 'Committed',
                value: '220 kg',
                sub: 'Dawn Dew Run',
              ),
              const SizedBox(width: 8),
              const _KpiCard(
                label: 'Grading',
                value: '100%',
                sub: 'Lab Inspected',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Field Operations 2x2 Grid
          Text('Field Operations & Actions',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.add_circle_outline,
                  title: 'Add New Produce',
                  subtitle: 'List batch for market',
                  isPrimary: true,
                  onTap: () => context.push('/produce/add-category'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.trending_up,
                  title: 'Live Demand',
                  subtitle: 'Spinach, Methi surge',
                  badge: '+18%',
                  onTap: () => context.go('/demand'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.warehouse_outlined,
                  title: 'Collection Point',
                  subtitle: 'Tomorrow 5:15 AM Hub',
                  onTap: () => context.push('/collection'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.mic_outlined,
                  title: 'Kisan Advisory',
                  subtitle: 'Ask pest or weather tip',
                  badge: 'Voice AI',
                  onTap: () => context.push('/advisory'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Shortcut Strip for Surplus, Inventory, Schemes, Store, Offline
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.inventory_2_outlined, size: 16),
                  label: const Text('Surplus Produce'),
                  onPressed: () => context.push('/surplus'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.warehouse_outlined, size: 16),
                  label: const Text('Inventory'),
                  onPressed: () => context.push('/inventory'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.account_balance_outlined, size: 16),
                  label: const Text('Govt Schemes'),
                  onPressed: () => context.push('/schemes'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.shopping_bag_outlined, size: 16),
                  label: const Text('FPO Store'),
                  onPressed: () => context.push('/store'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.cloud_sync_outlined, size: 16),
                  label: const Text('Offline Vault'),
                  onPressed: () => context.push('/offline-sync'),
                ),
              ],
            ),
          ),

          if (openDemand.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Direct Demand Request',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Text('Direct Escrow DBT',
                    style: TextStyle(fontSize: 11, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(openDemand.first['buyer'] as String,
                              style: Theme.of(context).textTheme.labelLarge),
                        ),
                        Text(
                          '₹${(openDemand.first['rate'] as num).toStringAsFixed(0)}/kg',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    Text(
                      '${openDemand.first['crop']} • Total ₹${(openDemand.first['total'] as num).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/demand'),
                            child: const Text('Review Lots'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              demand.respondToDemand(
                                  openDemand.first['id'] as String, 'ACCEPTED');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Demand accepted & order confirmed!')),
                              );
                            },
                            child: const Text('Accept Request'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          // Weekly Net Realization Summary Card
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceContainer,
                child: Icon(Icons.account_balance_wallet, color: AppColors.primary),
              ),
              title: Text(
                '₹${settlements.weeklyBalance.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              subtitle: Text(
                  'This Week\'s Net Realization • ${auth.bankName} ${auth.bankAccountMasked}'),
              trailing: TextButton(
                onPressed: () => context.go('/settlements'),
                child: const Text('Passbook ->'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _KpiCard({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: isPrimary ? null : Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon,
                    color: isPrimary ? Colors.white : AppColors.primary),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onTertiaryFixed),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isPrimary ? Colors.white : AppColors.onSurface,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isPrimary
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
