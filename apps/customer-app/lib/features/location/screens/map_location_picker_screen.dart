import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `map_location_picker`.
class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    final selected = AppConstants.pilotLocations[_selectedIdx];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Pin Delivery Location'),
      body: Column(
        children: [
          // Interactive simulated map canvas
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.margin),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'Delivering to ${selected['name']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.location_pin, size: 54, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Lat ${(selected['lat'] as double).toStringAsFixed(4)}, Lng ${(selected['lng'] as double).toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(AppConstants.pilotLocations.length, (i) {
                        final loc = AppConstants.pilotLocations[i];
                        final active = i == _selectedIdx;
                        return ChoiceChip(
                          label: Text(loc['name'] as String),
                          selected: active,
                          onSelected: (_) => setState(() => _selectedIdx = i),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom confirmation sheet
          Container(
            padding: const EdgeInsets.all(AppSpacing.margin),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              boxShadow: AppShadows.level3,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selected['name']} • ${selected['pinCode']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selected['hub']} • GPS coordinates require doorstep confirmation.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final settings = context.read<AppSettingsProvider>();
                        await settings.setDeliveryLocation(
                          selected['name'] as String,
                          selected['pinCode'] as String,
                        );
                        if (!context.mounted) return;
                        context.push('/confirm-address', extra: selected);
                      },
                      child: const Text('Confirm Pin & Add Doorstep Details'),
                    ),
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
