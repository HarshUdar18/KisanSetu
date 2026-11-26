import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'location_models.dart';
import 'location_repository.dart';

class KisanOsmMapPicker extends StatefulWidget {
  final LocationRepository? locationRepository;
  final LatLng initialCenter;
  final String userAgentPackageName;
  final List<NearbyHubModel> nearbyHubs;
  final List<LatLng> routePoints;
  final List<Polygon> boundaryPolygons;
  final void Function(LatLng point, GeocodeResultModel? resolved) onLocationSelected;

  const KisanOsmMapPicker({
    super.key,
    required this.locationRepository,
    required this.onLocationSelected,
    this.initialCenter = const LatLng(18.5204, 73.8567),
    this.userAgentPackageName = 'com.kisansetu.customer',
    this.nearbyHubs = const [],
    this.routePoints = const [],
    this.boundaryPolygons = const [],
  });

  @override
  State<KisanOsmMapPicker> createState() => _KisanOsmMapPickerState();
}

class _KisanOsmMapPickerState extends State<KisanOsmMapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  late LatLng _selectedPoint;
  List<GeocodeResultModel> _searchResults = const [];
  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  bool _isLocating = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialCenter;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearchSubmitted() async {
    final repo = widget.locationRepository;
    final query = _searchCtrl.text.trim();
    if (repo == null || query.length < 3) {
      setState(() => _statusMessage = 'Enter at least 3 characters to search.');
      return;
    }

    setState(() {
      _isSearching = true;
      _statusMessage = null;
    });
    try {
      final results = await repo.geocode(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          _statusMessage = 'No matching locations found.';
        }
      });
      if (results.isNotEmpty) {
        final first = results.first;
        _moveAndSelect(first.latLng, preResolved: first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _statusMessage = 'Search unavailable. You can tap the map to place your pin.';
      });
    }
  }

  Future<void> _useCurrentGps() async {
    setState(() {
      _isLocating = true;
      _statusMessage = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLocating = false;
          _statusMessage = 'GPS is turned off. Tap anywhere on the map to select manually.';
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
          _statusMessage = 'Location permission denied. Tap the map to place your pin.';
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
      setState(() => _isLocating = false);
      await _moveAndSelect(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _statusMessage = 'Unable to get GPS fix. Tap the map to place your pin.';
      });
    }
  }

  Future<void> _moveAndSelect(LatLng point, {GeocodeResultModel? preResolved}) async {
    if (!LocationCoordinateValidator.isValid(point.latitude, point.longitude)) {
      return;
    }
    setState(() {
      _selectedPoint = point;
      _searchResults = const [];
    });
    _mapController.move(point, 14.5);

    if (preResolved != null) {
      widget.onLocationSelected(point, preResolved);
      return;
    }

    final repo = widget.locationRepository;
    if (repo == null) {
      widget.onLocationSelected(point, null);
      return;
    }

    setState(() => _isReverseGeocoding = true);
    try {
      final resolved = await repo.reverseGeocode(point.latitude, point.longitude);
      if (!mounted) return;
      setState(() {
        _isReverseGeocoding = false;
        _statusMessage = null;
      });
      widget.onLocationSelected(point, resolved);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isReverseGeocoding = false;
        _statusMessage = 'Address lookup unavailable; coordinates are still captured.';
      });
      widget.onLocationSelected(point, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearchSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Search village, city, or pincode',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _onSearchSubmitted,
                          ),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _isLocating ? null : _useCurrentGps,
                tooltip: 'Use current GPS location',
                icon: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        if (_searchResults.length > 1)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _searchResults.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return ActionChip(
                  label: Text(
                    item.village ?? item.district ?? item.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () => _moveAndSelect(item.latLng, preResolved: item),
                );
              },
            ),
          ),
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 13.0,
                  onTap: (_, latLng) => _moveAndSelect(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: widget.userAgentPackageName,
                  ),
                  if (widget.boundaryPolygons.isNotEmpty)
                    PolygonLayer(polygons: widget.boundaryPolygons),
                  if (widget.routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: widget.routePoints,
                          strokeWidth: 4.5,
                          color: Colors.green.shade700,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPoint,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 42),
                      ),
                      ...widget.nearbyHubs.map(
                        (hub) => Marker(
                          point: hub.latLng,
                          width: 36,
                          height: 36,
                          child: Tooltip(
                            message: '${hub.hubName} (${hub.distanceKm.toStringAsFixed(1)} km)',
                            child: const Icon(Icons.warehouse, color: Colors.green, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        '© OpenStreetMap contributors',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
              if (_isReverseGeocoding)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Resolving address...'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
