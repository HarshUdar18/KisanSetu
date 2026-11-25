import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/mock_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `fpo_farmer_network_chronicles`.
class FpoNetworkScreen extends StatelessWidget {
  const FpoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'FPO Farmer Network & Chronicles'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY SOIL CHRONICLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tertiaryFixed,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Meet the Collectives Growing Your Morning Basket',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Every FPO is audited for soil health, fair farmgate payouts, and 12-hour harvest dispatch.',
                  style: TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...MockCustomerServices.farmers.map((f) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surfaceContainer,
                    child: Icon(Icons.agriculture, color: AppColors.primary),
                  ),
                  title: Text(f['name'] as String,
                      style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(
                    '${f['farmerName']} • ${f['cluster']} (${f['distanceKm']} km)\n${(f['crops'] as List).join(', ')}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/farmer/${f['id']}'),
                ),
              )),
        ],
      ),
    );
  }
}
