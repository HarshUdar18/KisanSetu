import 'package:latlong2/latlong.dart';

class LocationCoordinateValidator {
  static bool isValid(double latitude, double longitude) {
    if (latitude.isNaN || latitude.isInfinite || longitude.isNaN || longitude.isInfinite) {
      return false;
    }
    return latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;
  }
}

class GeocodeResultModel {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? village;
  final String? district;
  final String? state;
  final String? pincode;
  final String? country;
  final String provider;

  const GeocodeResultModel({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.village,
    this.district,
    this.state,
    this.pincode,
    this.country,
    this.provider = 'nominatim',
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory GeocodeResultModel.fromJson(Map<String, dynamic> json) {
    return GeocodeResultModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      displayName: json['displayName'] as String? ?? '',
      village: json['village'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String?,
      provider: json['provider'] as String? ?? 'nominatim',
    );
  }
}

class NearbyHubModel {
  final String hubId;
  final String hubCode;
  final String hubName;
  final String hubType;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String distanceType;

  const NearbyHubModel({
    required this.hubId,
    required this.hubCode,
    required this.hubName,
    required this.hubType,
    required this.address,
    required this.district,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.distanceType,
  });

  LatLng get latLng => LatLng(latitude, longitude);
  double get distanceKm => distanceMeters / 1000.0;

  factory NearbyHubModel.fromJson(Map<String, dynamic> json) {
    return NearbyHubModel(
      hubId: json['hubId'] as String? ?? '',
      hubCode: json['hubCode'] as String? ?? '',
      hubName: json['hubName'] as String? ?? '',
      hubType: json['hubType'] as String? ?? 'COLLECTION_HUB',
      address: json['address'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      distanceType: json['distanceType'] as String? ?? 'POSTGIS_GEOGRAPHY',
    );
  }
}

class RouteResultModel {
  final double distanceMeters;
  final double durationSeconds;
  final String travelMode;
  final String provider;
  final List<LatLng> geometry;
  final String disclaimer;

  const RouteResultModel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.travelMode,
    required this.provider,
    required this.geometry,
    required this.disclaimer,
  });

  double get distanceKm => distanceMeters / 1000.0;
  int get durationMinutes => (durationSeconds / 60.0).ceil();

  factory RouteResultModel.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['geometry'] as List<dynamic>? ?? const [];
    final points = rawCoords
        .whereType<Map<String, dynamic>>()
        .map((c) => LatLng(
              (c['latitude'] as num).toDouble(),
              (c['longitude'] as num).toDouble(),
            ))
        .toList();
    return RouteResultModel(
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      travelMode: json['travelMode'] as String? ?? 'driving',
      provider: json['provider'] as String? ?? 'osrm',
      geometry: points,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}

class FarmerFarmModel {
  final String id;
  final String farmName;
  final String? village;
  final String? taluka;
  final String? district;
  final String? state;
  final String? pincode;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  final double? landArea;
  final String landUnit;

  const FarmerFarmModel({
    required this.id,
    required this.farmName,
    this.village,
    this.taluka,
    this.district,
    this.state,
    this.pincode,
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.landArea,
    this.landUnit = 'acre',
  });

  factory FarmerFarmModel.fromJson(Map<String, dynamic> json) {
    return FarmerFarmModel(
      id: json['id'] as String? ?? '',
      farmName: json['farmName'] as String? ?? '',
      village: json['village'] as String?,
      taluka: json['taluka'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      formattedAddress: json['formattedAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      landArea: (json['landArea'] as num?)?.toDouble(),
      landUnit: json['landUnit'] as String? ?? 'acre',
    );
  }
}

class GeofenceValidationModel {
  final bool insideServiceArea;
  final bool serviceable;
  final String reasonCode;
  final String message;
  final String? zoneName;
  final String? localityId;
  final String? localityName;

  const GeofenceValidationModel({
    required this.insideServiceArea,
    required this.serviceable,
    required this.reasonCode,
    required this.message,
    this.zoneName,
    this.localityId,
    this.localityName,
  });

  factory GeofenceValidationModel.fromJson(Map<String, dynamic> json) {
    return GeofenceValidationModel(
      insideServiceArea: json['insideServiceArea'] as bool? ?? false,
      serviceable: json['serviceable'] as bool? ?? false,
      reasonCode: json['reasonCode'] as String? ?? 'OUTSIDE_SERVICE_AREA',
      message: json['message'] as String? ?? 'Sorry, Kisan Setu is not currently available at this location.',
      zoneName: json['zoneName'] as String?,
      localityId: json['localityId']?.toString(),
      localityName: json['localityName'] as String?,
    );
  }
}

class ServiceAreaSummaryModel {
  final String localityId;
  final String localityCode;
  final String localityName;
  final String localityStatus;
  final String zoneName;
  final bool hasActiveBoundary;

  const ServiceAreaSummaryModel({
    required this.localityId,
    required this.localityCode,
    required this.localityName,
    required this.localityStatus,
    required this.zoneName,
    required this.hasActiveBoundary,
  });

  factory ServiceAreaSummaryModel.fromJson(Map<String, dynamic> json) {
    return ServiceAreaSummaryModel(
      localityId: json['localityId']?.toString() ?? '',
      localityCode: json['localityCode'] as String? ?? '',
      localityName: json['localityName'] as String? ?? '',
      localityStatus: json['localityStatus'] as String? ?? 'DRAFT',
      zoneName: json['zoneName'] as String? ?? '',
      hasActiveBoundary: json['hasActiveBoundary'] as bool? ?? false,
    );
  }
}

List<List<LatLng>> parseGeoJsonPolygonRings(Map<String, dynamic> geoJson) {
  final type = geoJson['type'] as String? ?? '';
  final coords = geoJson['coordinates'] as List<dynamic>? ?? const [];
  final rings = <List<LatLng>>[];
  if (type == 'Polygon' && coords.isNotEmpty) {
    final outer = coords.first as List<dynamic>;
    rings.add(outer.map((pt) => LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble())).toList());
  } else if (type == 'MultiPolygon') {
    for (final poly in coords) {
      if (poly is List && poly.isNotEmpty) {
        final outer = poly.first as List<dynamic>;
        rings.add(outer.map((pt) => LatLng((pt[1] as num).toDouble(), (pt[0] as num).toDouble())).toList());
      }
    }
  }
  return rings;
}
