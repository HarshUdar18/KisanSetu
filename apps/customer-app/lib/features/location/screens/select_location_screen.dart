import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_models.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final bool returnSelectionOnly;

  const SelectLocationScreen({super.key, this.returnSelectionOnly = false});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _flatCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  Timer? _debounce;
  late final LocationRepository _locationRepo;

  bool _fetchingCurrent = false;
  bool _searching = false;
  bool _confirming = false;
  bool _navigating = false;

  String? _locationError;
  bool _showSettingsAction = false;
  List<GeocodeResultModel> _searchResults = const [];
  GeocodeResultModel? _pendingLocation;
  String _pendingSourceLabel = 'Selected Location';
  String _addressTag = 'HOME';

  @override
  void initState() {
    super.initState();
    _locationRepo = LocationRepository(
      dioClient: context.read<AddressProvider>().dioClient,
    );
    Future.microtask(() async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final addressProvider = context.read<AddressProvider>();
      if (auth.isAuthenticated && addressProvider.addresses.isEmpty) {
        await addressProvider.fetchAddresses();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _flatCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      setState(() {
        _searchResults = const [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _locationRepo.geocode(trimmed);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _searching = false;
          _locationError = results.isEmpty
              ? 'No matching locations found. Try another area or PIN code.'
              : null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _searching = false;
          _locationError = 'Unable to search locations right now. Please try again.';
        });
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_fetchingCurrent) return;
    final settings = context.read<AppSettingsProvider>();
    setState(() {
      _locationError = null;
      _showSettingsAction = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _locationError =
              'Device location services are turned off. Enable GPS or search your address manually.';
        });
        _searchFocus.requestFocus();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final allow = await _showPermissionRationaleDialog();
        if (allow != true || !mounted) return;
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }

      if (permission == LocationPermission.denied) {
        settings.setLocationPermission(PermissionStatusState.denied);
        setState(() {
          _locationError =
              'Location permission denied. You can search your location manually or skip for now.';
        });
        _searchFocus.requestFocus();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        settings.setLocationPermission(PermissionStatusState.permanentlyDenied);
        setState(() {
          _locationError =
              'Location permission is permanently disabled. Enable it in Settings or search manually below.';
          _showSettingsAction = true;
        });
        _searchFocus.requestFocus();
        return;
      }

      settings.setLocationPermission(PermissionStatusState.granted);
      setState(() => _fetchingCurrent = true);

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        if (!mounted) return;
        setState(() {
          _fetchingCurrent = false;
          _locationError =
              'Could not get your GPS location. Please search your address manually.';
        });
        _searchFocus.requestFocus();
        return;
      }

      final resolved =
          await _locationRepo.reverseGeocode(pos.latitude, pos.longitude);
      if (!mounted) return;

      if (resolved == null || resolved.displayName.trim().isEmpty) {
        setState(() {
          _fetchingCurrent = false;
          _locationError =
              'Could not resolve a readable address for your location. Please search manually.';
        });
        _searchFocus.requestFocus();
        return;
      }

      _selectGeocodeCandidate(resolved, sourceLabel: 'Current Location');
      setState(() => _fetchingCurrent = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fetchingCurrent = false;
        _locationError =
            'Unable to fetch current address. Please search your location manually.';
      });
      _searchFocus.requestFocus();
    }
  }

  Future<bool?> _showPermissionRationaleDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission Needed'),
        content: const Text(
          'Kisan Setu uses your location to fetch your delivery address and check fresh produce availability in your area.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _selectGeocodeCandidate(
    GeocodeResultModel result, {
    required String sourceLabel,
  }) {
    final extractedPin = _extractPincode(result);
    _pinCtrl.text = extractedPin;
    _flatCtrl.clear();
    setState(() {
      _pendingLocation = result;
      _pendingSourceLabel = sourceLabel;
      _searchResults = const [];
      _locationError = null;
    });
  }

  String _extractPincode(GeocodeResultModel result) {
    final direct = (result.pincode ?? '').trim();
    if (RegExp(r'^[1-9]\d{5}$').hasMatch(direct)) return direct;
    final match = RegExp(r'\b([1-9]\d{5})\b').firstMatch(result.displayName);
    return match?.group(1) ?? '';
  }

  String _shortLocationName(GeocodeResultModel result) {
    final locality = (result.village ?? '').trim();
    final city = (result.district ?? '').trim();
    if (locality.isNotEmpty && city.isNotEmpty && locality != city) {
      return '$locality, $city';
    }
    if (locality.isNotEmpty) return locality;
    if (city.isNotEmpty) return city;
    final parts = result.displayName
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0]}, ${parts[1]}';
    return parts.isNotEmpty ? parts.first : result.displayName;
  }

  Future<void> _confirmPendingLocation() async {
    final pending = _pendingLocation;
    if (pending == null || _confirming || _navigating) return;

    final pin = _pinCtrl.text.trim();
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pin)) {
      setState(() {
        _locationError = 'Please enter a valid 6-digit PIN code to save this address.';
      });
      return;
    }

    if (widget.returnSelectionOnly) {
      context.pop({
        'geocode': pending,
        'pincode': pin,
        'shortName': _shortLocationName(pending),
      });
      return;
    }

    setState(() {
      _confirming = true;
      _locationError = null;
    });

    final auth = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    final settings = context.read<AppSettingsProvider>();

    final shortName = _shortLocationName(pending);
    final flat = _flatCtrl.text.trim();
    final parts = pending.displayName
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final line1 = flat.isNotEmpty
        ? flat
        : (parts.isNotEmpty ? parts.first : shortName);
    final line2 = flat.isNotEmpty
        ? pending.displayName
        : (parts.length > 1 ? parts.skip(1).take(2).join(', ') : null);
    final city = (pending.district ?? pending.village ?? 'Pune').trim();
    final stateName = (pending.state ?? 'Maharashtra').trim();

    if (auth.isAuthenticated) {
      final saved = await addressProvider.addAddress(
        AddressModel(
          id: '',
          label: _addressTag,
          addressLine1: line1,
          addressLine2: line2,
          city: city.isNotEmpty ? city : 'Pune',
          state: stateName.isNotEmpty ? stateName : 'Maharashtra',
          pincode: pin,
          latitude: pending.latitude,
          longitude: pending.longitude,
          isDefault: true,
        ),
      );
      if (!mounted) return;
      if (!saved) {
        setState(() {
          _confirming = false;
          _locationError =
              addressProvider.errorMessage ?? 'Unable to save address. Please retry.';
        });
        return;
      }
      await addressProvider.fetchAddresses();
    }

    if (!mounted) return;
    await settings.setDeliveryLocation(
      shortName,
      pin,
      area: line1,
      fullAddress: pending.displayName,
      latitude: pending.latitude,
      longitude: pending.longitude,
    );

    if (!mounted) return;
    _goToDashboard();
  }

  Future<void> _selectSavedAddress(AddressModel address) async {
    if (_confirming || _navigating) return;
    setState(() => _confirming = true);

    final addressProvider = context.read<AddressProvider>();
    final settings = context.read<AppSettingsProvider>();

    await addressProvider.setDefaultAddress(address.id);
    await settings.syncFromDefaultAddress(address);

    if (!mounted) return;
    _goToDashboard();
  }

  Future<void> _skipLocation() async {
    if (_confirming || _navigating) return;
    await context.read<AppSettingsProvider>().skipLocation();
    if (!mounted) return;
    _goToDashboard();
  }

  void _goToDashboard() {
    if (_navigating || !mounted) return;
    _navigating = true;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final savedAddresses = addressProvider.addresses;
    final previewSaved = savedAddresses.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: context.canPop(),
        title: Text(
          'Select your location',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          TextButton(
            onPressed: _confirming ? null : _skipLocation,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            // Search Your Location
            TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Search your area, street, city, or PIN code',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          _debounce?.cancel();
                          setState(() {
                            _searchResults = const [];
                            _searching = false;
                            _locationError = null;
                          });
                        },
                      )
                    : null,
              ),
            ),

            if (_searching) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],

            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: _searchResults.map((result) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            _shortLocationName(result),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          subtitle: Text(
                            result.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _selectGeocodeCandidate(
                            result,
                            sourceLabel: 'Selected Location',
                          ),
                        ),
                        if (result != _searchResults.last) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Option 1 — Use My Current Location
            Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: _fetchingCurrent || _confirming ? null : _useCurrentLocation,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: _fetchingCurrent
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: AppColors.onSecondaryContainer,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use My Current Location',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fetchingCurrent
                                  ? 'Fetching your readable address...'
                                  : 'Automatically detect your delivery address using GPS',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.outline),
                    ],
                  ),
                ),
              ),
            ),

            if (_locationError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationError!,
                            style: const TextStyle(
                              color: AppColors.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showSettingsAction) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Geolocator.openAppSettings(),
                        child: const Text('Open App Settings'),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Selected / Reverse-Geocoded Address Confirmation Card
            if (_pendingLocation != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _pendingSourceLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pendingLocation!.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _flatCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Flat / House / Building (Optional)',
                        hintText: 'e.g. Flat 304, Green Park Heights',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'PIN Code',
                        hintText: '6-digit PIN code',
                      ),
                    ),
                    if (auth.isAuthenticated) ...[
                      const SizedBox(height: 10),
                      Text('Save As', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['HOME', 'WORK', 'OTHER'].map((tag) {
                          return ChoiceChip(
                            label: Text(tag),
                            selected: _addressTag == tag,
                            onSelected: (_) => setState(() => _addressTag = tag),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirming ? null : _confirmPendingLocation,
                        child: _confirming
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Confirm Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Option 2 — Saved Addresses (Authenticated Customers)
            if (auth.isAuthenticated) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Addresses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (savedAddresses.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        final selected = await context.push<AddressModel?>(
                          '/addresses',
                          extra: {'selectMode': true},
                        );
                        if (selected != null && mounted) {
                          await _selectSavedAddress(selected);
                        }
                      },
                      child: const Text('See All'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (addressProvider.isLoading && savedAddresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (savedAddresses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_off_outlined,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No saved addresses yet. Use your current location or search above to set your delivery address.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...previewSaved.map((addr) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainer,
                        child: Icon(
                          addr.label.toUpperCase() == 'WORK'
                              ? Icons.work_outline
                              : addr.label.toUpperCase() == 'HOME'
                                  ? Icons.home_outlined
                                  : Icons.place_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            addr.label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          if (addr.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        addr.fullAddressText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _confirming ? null : () => _selectSavedAddress(addr),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
