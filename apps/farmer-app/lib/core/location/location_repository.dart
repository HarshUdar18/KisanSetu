import '../network/dio_client.dart';
import 'location_models.dart';

class LocationRepository {
  final DioClient dioClient;

  LocationRepository({required this.dioClient});

  Future<List<GeocodeResultModel>> geocode(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
    final res = await dioClient.dio.get(
      '/locations/geocode',
      queryParameters: {'q': trimmed},
    );
    final data = (res.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(GeocodeResultModel.fromJson)
        .toList();
  }

  Future<GeocodeResultModel?> reverseGeocode(double latitude, double longitude) async {
    if (!LocationCoordinateValidator.isValid(latitude, longitude)) {
      throw ArgumentError('Coordinates out of valid range');
    }
    final res = await dioClient.dio.get(
      '/locations/reverse-geocode',
      queryParameters: {'lat': latitude, 'lon': longitude},
    );
    final data = (res.data as Map<String, dynamic>)['data'];
    if (data is Map<String, dynamic>) {
      return GeocodeResultModel.fromJson(data);
    }
    return null;
  }

  Future<List<NearbyHubModel>> findNearbyHubs(
    double latitude,
    double longitude, {
    double radiusKm = 50,
    int limit = 20,
    String? hubType,
  }) async {
    if (!LocationCoordinateValidator.isValid(latitude, longitude)) {
      throw ArgumentError('Coordinates out of valid range');
    }
    final res = await dioClient.dio.get(
      '/locations/nearby/hubs',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'radiusKm': radiusKm,
        'limit': limit,
        if (hubType != null && hubType.isNotEmpty) 'hubType': hubType,
      },
    );
    final data = (res.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(NearbyHubModel.fromJson)
        .toList();
  }

  Future<RouteResultModel> calculateRoute(
    double originLatitude,
    double originLongitude,
    double destinationLatitude,
    double destinationLongitude, {
    String travelMode = 'driving',
  }) async {
    if (!LocationCoordinateValidator.isValid(originLatitude, originLongitude) ||
        !LocationCoordinateValidator.isValid(destinationLatitude, destinationLongitude)) {
      throw ArgumentError('Coordinates out of valid range');
    }
    final res = await dioClient.dio.post(
      '/locations/routes',
      data: {
        'originLatitude': originLatitude,
        'originLongitude': originLongitude,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
        'travelMode': travelMode,
      },
    );
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return RouteResultModel.fromJson(data);
  }

  Future<List<FarmerFarmModel>> listFarms() async {
    final res = await dioClient.dio.get('/farmer/farms');
    final data = (res.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(FarmerFarmModel.fromJson)
        .toList();
  }

  Future<FarmerFarmModel> createFarm({
    required String farmName,
    String? village,
    String? taluka,
    String? district,
    String? state,
    String? pincode,
    String? formattedAddress,
    double? latitude,
    double? longitude,
    double? landArea,
    String landUnit = 'acre',
  }) async {
    final res = await dioClient.dio.post(
      '/farmer/farms',
      data: {
        'farmName': farmName,
        'village': ?village,
        'taluka': ?taluka,
        'district': ?district,
        'state': ?state,
        'pincode': ?pincode,
        'formattedAddress': ?formattedAddress,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'landArea': ?landArea,
        'landUnit': landUnit,
      },
    );
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return FarmerFarmModel.fromJson(data);
  }

  Future<GeofenceValidationModel> validateServiceArea(
    double latitude,
    double longitude, {
    String requestedOperation = 'FARM_COLLECTION',
    String? pinCode,
    String? locality,
    String? city,
    String? state,
  }) async {
    if (!LocationCoordinateValidator.isValid(latitude, longitude)) {
      throw ArgumentError('Coordinates out of valid range');
    }
    final res = await dioClient.dio.post(
      '/service-areas/validate',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'requestedOperation': requestedOperation,
        if (pinCode != null && pinCode.isNotEmpty) 'pinCode': pinCode,
        if (locality != null && locality.isNotEmpty) 'locality': locality,
        if (city != null && city.isNotEmpty) 'city': city,
        if (state != null && state.isNotEmpty) 'state': state,
      },
    );
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return GeofenceValidationModel.fromJson(data);
  }
}
