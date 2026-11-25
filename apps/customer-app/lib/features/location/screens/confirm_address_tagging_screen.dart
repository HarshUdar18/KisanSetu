import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

/// Implements Stitch `confirm_delivery_address_tagging`.
class ConfirmAddressTaggingScreen extends StatefulWidget {
  final Map<String, dynamic> locationData;

  const ConfirmAddressTaggingScreen({super.key, this.locationData = const {}});

  @override
  State<ConfirmAddressTaggingScreen> createState() =>
      _ConfirmAddressTaggingScreenState();
}

class _ConfirmAddressTaggingScreenState
    extends State<ConfirmAddressTaggingScreen> {
  final _flatCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  String _tag = 'HOME';
  bool _saved = false;

  @override
  void dispose() {
    _flatCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areaName = widget.locationData['name'] as String? ?? 'Kothrud, Pune';
    final pinCode = widget.locationData['pinCode'] as String? ?? '411038';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Confirm Doorstep Details'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: _saved
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(Icons.check, size: 48, color: AppColors.onSecondaryContainer),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Address Saved Successfully',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$areaName ($pinCode) is tagged as $_tag and ready for morning harvest delivery.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$areaName • $pinCode',
                                  style: Theme.of(context).textTheme.labelLarge),
                              Text('Pinned on Map',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Doorstep Specifics',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _flatCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Flat / House / Wing / Gate Code',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _landmarkCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nearby Landmark (Optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Save As', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: ['HOME', 'WORK', 'OTHER'].map((t) {
                      return ChoiceChip(
                        label: Text(t),
                        selected: _tag == t,
                        onSelected: (_) => setState(() => _tag = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await context.read<AddressProvider>().addAddress(
                              AddressModel(
                                id: '',
                                label: _tag,
                                addressLine1: _flatCtrl.text.trim().isEmpty
                                    ? areaName
                                    : _flatCtrl.text.trim(),
                                addressLine2: _landmarkCtrl.text.trim(),
                                city: 'Pune',
                                state: 'Maharashtra',
                                pincode: pinCode,
                                isDefault: true,
                              ),
                            );
                        if (mounted) setState(() => _saved = true);
                      },
                      child: const Text('Confirm & Save Address'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
