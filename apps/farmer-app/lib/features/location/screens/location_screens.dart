import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/farmer_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

class LocationPrimerScreen extends StatelessWidget {
  const LocationPrimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farm Location & Collection Hub'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.surfaceContainer,
                child: Icon(Icons.location_on, size: 48, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text('Why Farm Location Is Needed',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'GPS is optional. Your farm location helps match nearby FPO Collection Hubs, hyperlocal weather advisories, and pickup transporters. Farm location and collection point are configured separately.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  settings.setLocationPermission(PermissionState.granted);
                  context.push('/collection-points');
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Allow Location & Find Collection Hubs'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/select-farm-location'),
                child: const Text('Enter Village / District Manually'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  settings.setLocationPermission(PermissionState.denied);
                  context.push('/location-permission-denied');
                },
                child: const Text('Skip GPS / Permission Denied'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationPermissionDeniedScreen extends StatelessWidget {
  const LocationPermissionDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Location Settings Guidance'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Text(
                'Location permission is turned off. You are NOT blocked—enter your village, taluka, and district manually below or enable GPS in Android Settings > Apps > Kisan Setu Farmer > Permissions.',
                style: TextStyle(color: AppColors.onErrorContainer),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/select-farm-location'),
                child: const Text('Select Farm Location Manually'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectFarmLocationScreen extends StatefulWidget {
  const SelectFarmLocationScreen({super.key});

  @override
  State<SelectFarmLocationScreen> createState() =>
      _SelectFarmLocationScreenState();
}

class _SelectFarmLocationScreenState extends State<SelectFarmLocationScreen> {
  final _villageCtrl = TextEditingController(text: 'Mulshi');
  final _talukaCtrl = TextEditingController(text: 'Mulshi');
  final _districtCtrl = TextEditingController(text: 'Pune');
  String _stateName = 'Maharashtra';

  @override
  void dispose() {
    _villageCtrl.dispose();
    _talukaCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Select Farm Location'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          TextField(
            controller: _villageCtrl,
            decoration: const InputDecoration(labelText: 'Village / Search Village'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _talukaCtrl,
            decoration: const InputDecoration(labelText: 'Taluka'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _districtCtrl,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _stateName,
            decoration: const InputDecoration(labelText: 'State'),
            items: ['Maharashtra', 'Karnataka', 'Madhya Pradesh', 'Gujarat']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _stateName = v!),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/farm-map-picker'),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pick Farm Plot on Map'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await context.read<FarmerSettingsProvider>().updateFarmLocation(
                    village: _villageCtrl.text.trim(),
                    taluka: _talukaCtrl.text.trim(),
                    district: _districtCtrl.text.trim(),
                    stateName: _stateName,
                  );
              if (!context.mounted) return;
              context.push('/collection-points');
            },
            child: const Text('Confirm Farm Location & Choose Hub'),
          ),
        ],
      ),
    );
  }
}

class FarmMapPickerScreen extends StatelessWidget {
  const FarmMapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farm Location Map Picker'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_pin, size: 56, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text('Gat No. 142, Paud Road, Mulshi, Pune'),
                    Text('18.5011° N, 73.5130° E',
                        style: TextStyle(fontSize: 12, color: AppColors.outline)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Confirm Farm Plot Coordinates'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionPointsScreen extends StatelessWidget {
  const CollectionPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Select Collection Point'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Text('Nearby Verified FPO Hubs',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          ...AppConstants.collectionHubs.map((hub) {
            final selected = settings.selectedHubId == hub['id'];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: selected
                      ? AppColors.primary
                      : AppColors.surfaceContainer,
                  child: Icon(Icons.warehouse,
                      color: selected ? Colors.white : AppColors.primary),
                ),
                title: Text(hub['name'] as String),
                subtitle: Text(
                    '${hub['taluka']}, ${hub['district']} • ${hub['distanceKm']} km\nSlots: ${(hub['slots'] as List).join(' | ')}'),
                isThreeLine: true,
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await settings.selectCollectionHub(
                      hub['id'] as String, hub['name'] as String);
                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
