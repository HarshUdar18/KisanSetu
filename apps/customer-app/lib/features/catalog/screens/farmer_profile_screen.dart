import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/mock_services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `farmer_profile_origin_story`.
class FarmerProfileScreen extends StatelessWidget {
  final String farmerId;

  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    final farmer = MockCustomerServices.farmers.firstWhere(
      (f) => f['id'] == farmerId,
      orElse: () => MockCustomerServices.farmers.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Farmer Profile & Origin Story'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Icon(Icons.person, size: 38, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer['farmerName'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        farmer['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '★ ${farmer['rating']} • ${farmer['deliveries']} Deliveries',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Origin & Farming Practice',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(farmer['story'] as String,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        farmer['certified'] as String,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
          Text('Active Harvest Crops', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (farmer['crops'] as List<dynamic>)
                .map((c) => Chip(label: Text(c.toString())))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => context.push('/catalog'),
            child: const Text('Shop Produce from This Collective'),
          ),
        ],
      ),
    );
  }
}
