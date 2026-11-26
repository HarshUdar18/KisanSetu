import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/location/kisan_osm_map_picker.dart';
import '../../../core/location/location_models.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/network/dio_client.dart';
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
                onPressed: () async {
                  try {
                    var permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                    }
                    if (!context.mounted) return;
                    if (permission == LocationPermission.always ||
                        permission == LocationPermission.whileInUse) {
                      settings.setLocationPermission(PermissionState.granted);
                      context.push('/farm-map-picker', extra: {'autoDetect': true});
                    } else {
                      settings.setLocationPermission(
                        permission == LocationPermission.deniedForever
                            ? PermissionState.permanentlyDenied
                            : PermissionState.denied,
                      );
                      context.push('/location-permission-denied');
                    }
                  } catch (_) {
                    if (!context.mounted) return;
                    settings.setLocationPermission(PermissionState.denied);
                    context.push('/location-permission-denied');
                  }
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

class FarmMapPickerScreen extends StatefulWidget {
  final bool autoDetect;
  const FarmMapPickerScreen({super.key, this.autoDetect = true});

  @override
  State<FarmMapPickerScreen> createState() => _FarmMapPickerScreenState();
}

class _FarmMapPickerScreenState extends State<FarmMapPickerScreen> {
  late LatLng _selectedPoint;
  GeocodeResultModel? _resolved;
  List<NearbyHubModel> _nearbyHubs = const [];
  List<LatLng> _routePoints = const [];
  RouteResultModel? _activeRoute;
  GeofenceValidationModel? _geofenceResult;
  late final LocationRepository _locationRepo;
  bool _autoDetecting = false;
  bool _navigated = false;
  String? _gpsStatusError;

  @override
  void initState() {
    super.initState();
    final settings = context.read<FarmerSettingsProvider>();
    _selectedPoint = LatLng(
      settings.farmLatitude ?? 18.5204,
      settings.farmLongitude ?? 73.8567,
    );
    _locationRepo = LocationRepository(dioClient: context.read<DioClient>());
    if (widget.autoDetect) {
      Future.microtask(_runAutoDetectAndProceed);
    } else {
      _loadNearbyHubs(_selectedPoint);
      _validateFarmPoint(_selectedPoint);
    }
  }

  Future<void> _runAutoDetectAndProceed() async {
    if (!mounted || _autoDetecting) return;
    setState(() {
      _autoDetecting = true;
      _gpsStatusError = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        setState(() {
          _autoDetecting = false;
          _gpsStatusError = 'Location services (GPS) are disabled. Enable GPS or place your pin manually.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _autoDetecting = false;
          _gpsStatusError = permission == LocationPermission.deniedForever
              ? 'Location permission permanently denied. Enable in Android Settings or place your pin manually.'
              : 'Location permission denied. Retry or place your pin manually.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;

      final point = LatLng(pos.latitude, pos.longitude);
      if (!LocationCoordinateValidator.isValid(point.latitude, point.longitude)) {
        setState(() {
          _autoDetecting = false;
          _gpsStatusError = 'Invalid GPS coordinates received. Please confirm manually.';
        });
        return;
      }

      GeocodeResultModel? resolved;
      try {
        resolved = await _locationRepo
            .reverseGeocode(point.latitude, point.longitude)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Reverse geocoding failure must not block valid GPS coordinates
      }
      if (!mounted) return;

      final settings = context.read<FarmerSettingsProvider>();
      await settings.updateFarmLocation(
        village: resolved?.village ?? settings.village,
        taluka: settings.taluka,
        district: resolved?.district ?? settings.district,
        stateName: resolved?.state ?? settings.stateName,
        latitude: point.latitude,
        longitude: point.longitude,
      );
      if (!mounted) return;

      setState(() {
        _selectedPoint = point;
        _resolved = resolved;
        _autoDetecting = false;
      });

      if (!_navigated) {
        _navigated = true;
        context.push('/collection-points');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _autoDetecting = false;
        _gpsStatusError = 'GPS request timed out. Tap the map or retry to set your farm location.';
      });
    }
  }

  Future<void> _validateFarmPoint(LatLng point) async {
    try {
      final res = await _locationRepo.validateServiceArea(
        point.latitude,
        point.longitude,
        requestedOperation: 'FARM_COLLECTION',
      );
      if (mounted) {
        setState(() => _geofenceResult = res);
      }
    } catch (_) {}
  }

  Future<void> _loadNearbyHubs(LatLng point) async {
    try {
      final hubs = await _locationRepo.findNearbyHubs(point.latitude, point.longitude, radiusKm: 80, limit: 10);
      if (mounted) {
        setState(() => _nearbyHubs = hubs);
      }
      if (hubs.isNotEmpty) {
        final route = await _locationRepo.calculateRoute(
          point.latitude,
          point.longitude,
          hubs.first.latitude,
          hubs.first.longitude,
        );
        if (mounted) {
          setState(() {
            _activeRoute = route;
            _routePoints = route.geometry;
          });
        }
      }
    } catch (_) {
      // Non-blocking when offline/unauthenticated
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaLabel = _resolved?.village ??
        _resolved?.district ??
        (_resolved?.displayName.isNotEmpty == true ? _resolved!.displayName : 'Selected Farm Plot');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farm / Shop Location'),
      body: Column(
        children: [
          if (_autoDetecting)
            const LinearProgressIndicator(),
          if (_gpsStatusError != null)
            Container(
              width: double.infinity,
              color: AppColors.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _gpsStatusError!,
                      style: const TextStyle(color: AppColors.onErrorContainer, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _runAutoDetectAndProceed,
                    child: const Text('Retry GPS'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: KisanOsmMapPicker(
              locationRepository: _locationRepo,
              initialCenter: _selectedPoint,
              userAgentPackageName: 'com.kisansetu.farmer',
              nearbyHubs: _nearbyHubs,
              routePoints: _routePoints,
              onLocationSelected: (point, resolved) {
                setState(() {
                  _selectedPoint = point;
                  _resolved = resolved;
                });
                _loadNearbyHubs(point);
                _validateFarmPoint(point);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.margin),
            color: AppColors.surfaceContainerLowest,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(areaLabel, style: Theme.of(context).textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (_geofenceResult != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _geofenceResult!.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _geofenceResult!.serviceable ? AppColors.primary : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Lat ${_selectedPoint.latitude.toStringAsFixed(5)}, Lon ${_selectedPoint.longitude.toStringAsFixed(5)}'
                    '${_activeRoute != null ? ' • Route to nearest hub: ${_activeRoute!.distanceKm.toStringAsFixed(1)} km (~${_activeRoute!.durationMinutes} min)' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final settings = context.read<FarmerSettingsProvider>();
                        await settings.updateFarmLocation(
                          village: _resolved?.village ?? settings.village,
                          taluka: settings.taluka,
                          district: _resolved?.district ?? settings.district,
                          stateName: _resolved?.state ?? settings.stateName,
                          latitude: _selectedPoint.latitude,
                          longitude: _selectedPoint.longitude,
                        );
                        try {
                          await _locationRepo.createFarm(
                            farmName: settings.farmName,
                            village: _resolved?.village ?? settings.village,
                            taluka: settings.taluka,
                            district: _resolved?.district ?? settings.district,
                            state: _resolved?.state ?? settings.stateName,
                            pincode: _resolved?.pincode,
                            formattedAddress: _resolved?.displayName,
                            latitude: _selectedPoint.latitude,
                            longitude: _selectedPoint.longitude,
                          );
                        } catch (_) {
                          // If farmer is in pre-login onboarding, coordinates are kept in FarmerSettingsProvider
                        }
                        if (!context.mounted) return;
                        context.pop();
                      },
                      child: const Text('Confirm Farm Plot Coordinates'),
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

class CollectionPointsScreen extends StatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  State<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  List<NearbyHubModel> _hubs = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHubs();
  }

  Future<void> _loadHubs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = context.read<FarmerSettingsProvider>();
      final repo = LocationRepository(dioClient: context.read<DioClient>());
      final hubs = await repo.findNearbyHubs(
        settings.farmLatitude ?? 18.5204,
        settings.farmLongitude ?? 73.8567,
        radiusKm: 150,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _hubs = hubs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Unable to fetch nearby collection points. Check your connection and retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FarmerSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Select Collection Point'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.margin),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Continue to Sign In'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.margin),
                  children: [
                    Text('Nearby Verified FPO Hubs (${_hubs.length})',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    if (_hubs.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No active collection point is currently available for your location.'),
                        ),
                      ),
                    ..._hubs.map((hub) {
                      final selected = settings.selectedHubId == hub.hubId;
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
                          title: Text(hub.hubName),
                          subtitle: Text(
                            '${hub.address.isNotEmpty ? '${hub.address}, ' : ''}${hub.district}, ${hub.state} • ${hub.distanceKm.toStringAsFixed(1)} km (${hub.hubCode})',
                          ),
                          trailing: selected
                              ? const Icon(Icons.check_circle, color: AppColors.primary)
                              : null,
                          onTap: () async {
                            final dioClient = context.read<DioClient>();
                            await settings.selectCollectionHub(hub.hubId, hub.hubName);
                            try {
                              await dioClient.post('/farmer/collection-point/assign', data: {
                                'hubId': hub.hubId,
                              });
                            } catch (_) {
                              // Pre-login onboarding persists selection in FarmerSettingsProvider
                            }
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
