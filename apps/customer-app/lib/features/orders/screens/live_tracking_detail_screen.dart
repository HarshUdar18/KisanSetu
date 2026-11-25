import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `live_delivery_tracking_detail`.
class LiveTrackingDetailScreen extends StatelessWidget {
  final String orderId;

  const LiveTrackingDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Delivery Partner Status'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.electric_rickshaw, size: 52, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text(
                    'Dispatched from Kothrud Micro-Station',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'ETA: Tomorrow, 6:45 AM • Cold-Chain EV Van',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Vikram Kadam'),
              subtitle: const Text('Kisan Setu EV Partner • MH-12-KS-4410'),
              trailing: IconButton(
                icon: const Icon(Icons.support_agent, color: AppColors.primary),
                onPressed: () => context.push('/support-chat'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zero-Plastic Cold-Chain Handling',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Your produce is transported in insulated crates at 10°C from Pune West Hub.',
                    style: Theme.of(context).textTheme.bodySmall,
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
