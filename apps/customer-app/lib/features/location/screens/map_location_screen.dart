import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/location/location_models.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/address_provider.dart';

/// Full-screen interactive OpenStreetMap location picker with fixed center pin,
/// debounced search, GPS current-location button, and bottom address preview.
class MapLocationScreen extends StatefulWidget {
  final bool returnSelectionOnly;
  final bool autoLocateOnInit;

  const MapLocationScreen({
    super.key,
    this.returnSelectionOnly = false,
    this.autoLocateOnInit = true,
  });

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  late final LocationRepository _locationRepo;

  Timer? _searchDebounce;
  Timer? _reverseDebounce;

  LatLng _centerPoint = const LatLng(18.6512, 73.7689);
  GeocodeResultModel? _selectedGeocode;
  List<GeocodeResultModel> _searchResults = const [];
  bool _isSearching = false;
  bool _isResolving = false;
  bool _isLocating = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _locationRepo = LocationRepository(
      dioClient: context.read<AddressProvider>().dioClient,
    );
    Future.microtask(_initDefaultOrCurrent);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reverseDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initDefaultOrCurrent() async {
    final existing = context.read<AddressProvider>().defaultAddress;
    if (existing?.latitude != null && existing?.longitude != null) {
      final pt = LatLng(existing!.latitude!, existing.longitude!);
      setState(() => _centerPoint = pt);
      _mapController.move(pt, 15.5);
      await _reverseGeocode(pt);
    } else if (widget.autoLocateOnInit) {
      await _goToCurrentLocation(silentIfDenied: true);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      setState(() {
        _isSearching = true;
        _statusMessage = null;
      });
      try {
        final results = await _locationRepo.geocode(query);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
          if (results.isEmpty) {
            _statusMessage = 'No matching locations found. Try another area or PIN.';
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
          _statusMessage = 'Location search unavailable. Move the map pin manually.';
        });
      }
    });
  }

  void _onSearchResultSelected(GeocodeResultModel result) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedGeocode = result;
      _centerPoint = result.latLng;
      _searchResults = const [];
      _searchCtrl.text = _shortName(result);
      _statusMessage = null;
    });
    _mapController.move(result.latLng, 16.0);
  }

  Future<void> _goToCurrentLocation({bool silentIfDenied = false}) async {
    setState(() {
      _isLocating = true;
      _statusMessage = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          if (!silentIfDenied) {
            _statusMessage =
                'Location services are turned off. Please enable GPS or search manually.';
          }
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
          _isLocating = false;
          if (!silentIfDenied) {
            _statusMessage =
                'Location permission denied. You can search your delivery location above.';
          }
        });
        return;
      }

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

      if (!mounted) return;
      if (pos == null) {
        setState(() {
          _isLocating = false;
          if (!silentIfDenied) {
            _statusMessage =
                'Unable to get current GPS location. Please search manually.';
          }
        });
        return;
      }

      final pt = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _centerPoint = pt;
        _isLocating = false;
      });
      _mapController.move(pt, 16.0);
      await _reverseGeocode(pt);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        if (!silentIfDenied) {
          _statusMessage =
              'Could not access GPS. Please search your location manually.';
        }
      });
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      final center = event.camera.center;
      _centerPoint = center;
      _reverseDebounce?.cancel();
      _reverseDebounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) _reverseGeocode(center);
      });
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() {
      _isResolving = true;
      _statusMessage = null;
    });
    try {
      final resolved =
          await _locationRepo.reverseGeocode(point.latitude, point.longitude);
      if (!mounted) return;
      setState(() {
        _selectedGeocode = resolved;
        _isResolving = false;
        if (resolved == null) {
          _statusMessage =
              'Could not resolve a street address here. Move the pin or search above.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResolving = false;
        _statusMessage = 'Unable to fetch address for this point.';
      });
    }
  }

  String _extractPincode(GeocodeResultModel result) {
    final direct = (result.pincode ?? '').trim();
    if (RegExp(r'^[1-9]\d{5}$').hasMatch(direct)) return direct;
    final match = RegExp(r'\b([1-9]\d{5})\b').firstMatch(result.displayName);
    return match?.group(1) ?? '';
  }

  String _shortName(GeocodeResultModel result) {
    final village = (result.village ?? '').trim();
    final district = (result.district ?? '').trim();
    if (village.isNotEmpty && district.isNotEmpty && village != district) {
      return '$village, $district';
    }
    if (village.isNotEmpty) return village;
    if (district.isNotEmpty) return district;
    final first = result.displayName.split(',').first.trim();
    return first.isNotEmpty ? first : 'Selected Location';
  }

  Future<void> _completeAddressDetails() async {
    final geo = _selectedGeocode;
    if (geo == null) return;

    final payload = {
      'geocode': geo,
      'pincode': _extractPincode(geo),
      'shortName': _shortName(geo),
    };

    if (widget.returnSelectionOnly) {
      context.pop(payload);
      return;
    }

    final savedAddress = await context.push<dynamic>(
      '/add-address',
      extra: {'initialLocation': payload},
    );
    if (!mounted) return;
    if (savedAddress != null) {
      context.pop(savedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geo = _selectedGeocode;
    final titleText = geo != null
        ? _shortName(geo)
        : (_isResolving
            ? 'Fetching delivery address...'
            : 'Move map to select location');
    final subtitleText = geo != null
        ? geo.displayName
        : (_statusMessage ??
            'Drag the map or tap "Go to current location" to pinpoint your address');

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Dark-green header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'SELECT DELIVERY LOCATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Map + Search + Bottom Preview Card
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _centerPoint,
                      initialZoom: 15.0,
                      onMapEvent: _onMapEvent,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.kisansetu.customer',
                      ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Fixed center delivery marker
                  const IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 46,
                              color: AppColors.primary,
                            ),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0x66005128),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Search Bar & Dropdown Results
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      children: [
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search for location',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : (_searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            setState(
                                              () => _searchResults = const [],
                                            );
                                          },
                                        )
                                      : null),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        if (_searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppShadows.level2,
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final item = _searchResults[idx];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    _shortName(item),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _onSearchResultSelected(item),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom Current Location Button + Address Preview Card
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton.icon(
                            onPressed: _isLocating
                                ? null
                                : () => _goToCurrentLocation(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 4,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: _isLocating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: const Text(
                              'Go to current location',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 16,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            titleText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            subtitleText,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: (geo != null && !_isResolving)
                                        ? _completeAddressDetails
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          AppColors.outlineVariant,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Complete address details',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
