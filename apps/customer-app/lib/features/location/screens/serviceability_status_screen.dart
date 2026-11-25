import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../providers/address_provider.dart';

/// Implements Stitch:
/// - `delivery_serviceability_checking`
/// - `delivery_available`
/// - `delivery_not_available`
class ServiceabilityStatusScreen extends StatefulWidget {
  final String pinCode;
  final String? areaName;

  const ServiceabilityStatusScreen({
    super.key,
    required this.pinCode,
    this.areaName,
  });

  @override
  State<ServiceabilityStatusScreen> createState() =>
      _ServiceabilityStatusScreenState();
}

class _ServiceabilityStatusScreenState
    extends State<ServiceabilityStatusScreen> {
  ServiceabilityResult? _result;
  bool _notifiedWaitlist = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final res = await context
          .read<AddressProvider>()
          .checkServiceability(widget.pinCode);
      if (mounted) setState(() => _result = res);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final isChecking = provider.isCheckingServiceability || _result == null;
    final available = _result?.isServiceable ?? false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Serviceability Status'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: isChecking
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(strokeWidth: 4),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Verifying Farm-to-Door Route',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Checking active FPO cold-chain hubs for PIN ${widget.pinCode}...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : available
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 56,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Delivery Available!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _result?.message ??
                              '12-Hour Morning Harvest delivery is active in ${_result?.serviceAreaName ?? widget.pinCode}.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hub: ${_result?.serviceAreaName ?? "Pune Hub"} • Free delivery above ₹299',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Start Shopping Fresh Produce'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: AppColors.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_off_rounded,
                            size: 52,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          "We Don't Deliver Here Yet",
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _result?.message ??
                              'PIN ${widget.pinCode} is outside our active Pune pilot corridors (411005, 411035, 411038).',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _notifiedWaitlist
                                ? null
                                : () => setState(() => _notifiedWaitlist = true),
                            icon: Icon(
                              _notifiedWaitlist
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                            ),
                            label: Text(_notifiedWaitlist
                                ? 'Added to Expansion Waitlist!'
                                : 'Notify Me When Available'),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            child: const Text('Change Delivery Location'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Browse Catalog Anyway'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
