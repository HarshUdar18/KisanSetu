import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `farmer_profile_origin_story`.
class FarmerProfileScreen extends StatelessWidget {
  final String farmerId;

  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Farmer Profile & Origin Story'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Farmer Reference: $farmerId',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                const Text(
                  'Origin details are served from verified FPO collectives in the live network.',
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/fpo-network'),
                  child: const Text('View Verified FPO Network'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
