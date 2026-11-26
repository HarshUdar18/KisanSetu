import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/core/location/kisan_osm_map_picker.dart';
import 'package:kisansetu_customer_app/core/location/location_models.dart';
import 'package:kisansetu_customer_app/features/catalog/models/product_model.dart';

void main() {
  test('LocationCoordinateValidator rejects out-of-range coordinates', () {
    expect(LocationCoordinateValidator.isValid(18.5204, 73.8567), isTrue);
    expect(LocationCoordinateValidator.isValid(91.0, 73.8567), isFalse);
    expect(LocationCoordinateValidator.isValid(18.5204, -181.0), isFalse);
    expect(LocationCoordinateValidator.isValid(double.nan, 73.8567), isFalse);
  });

  test('GeocodeResultModel & RouteResultModel parse GeoJSON-converted coordinates', () {
    final geo = GeocodeResultModel.fromJson({
      'latitude': 18.5204,
      'longitude': 73.8567,
      'displayName': 'Pune, Maharashtra, India',
      'village': 'Pune',
      'district': 'Pune',
      'state': 'Maharashtra',
      'pincode': '411001',
    });
    expect(geo.latLng.latitude, 18.5204);
    expect(geo.pincode, '411001');

    final route = RouteResultModel.fromJson({
      'distanceMeters': 12500.0,
      'durationSeconds': 1200.0,
      'travelMode': 'driving',
      'provider': 'osrm',
      'geometry': [
        {'latitude': 18.5204, 'longitude': 73.8567},
        {'latitude': 18.5300, 'longitude': 73.8700},
      ],
      'disclaimer': 'Planning estimate',
    });
    expect(route.distanceKm, 12.5);
    expect(route.durationMinutes, 20);
    expect(route.geometry.length, 2);
  });

  test('GeofenceValidationModel & GeoJSON polygon parsing work accurately', () {
    final outside = GeofenceValidationModel.fromJson({
      'insideServiceArea': false,
      'serviceable': false,
      'reasonCode': 'OUTSIDE_SERVICE_AREA',
      'message': 'Sorry, Kisan Setu is not currently available at this location.',
    });
    expect(outside.serviceable, isFalse);
    expect(outside.reasonCode, 'OUTSIDE_SERVICE_AREA');

    final rings = parseGeoJsonPolygonRings({
      'type': 'MultiPolygon',
      'coordinates': [
        [
          [
            [73.84, 18.52],
            [73.86, 18.52],
            [73.86, 18.54],
            [73.84, 18.54],
            [73.84, 18.52],
          ]
        ]
      ],
    });
    expect(rings.length, 1);
    expect(rings.first.length, 5);
    expect(rings.first.first.latitude, 18.52);
    expect(rings.first.first.longitude, 73.84);
  });

  testWidgets('KisanOsmMapPicker renders OpenStreetMap attribution', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KisanOsmMapPicker(
            locationRepository: null,
            onLocationSelected: (_, _) {},
          ),
        ),
      ),
    );
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
  });

  test('ProductModel parses stockStatus and does not fabricate stockQuantity', () {
    final outOfStock = ProductModel.fromJson({
      'id': 'p1',
      'name': 'Potato',
      'currentPrice': 0.0,
      'stockQuantity': 0.0,
      'stockStatus': 'OUT_OF_STOCK',
    });
    expect(outOfStock.isInStock, isFalse);
    expect(outOfStock.stockQuantity, 0.0);

    final inStock = ProductModel.fromJson({
      'id': 'p2',
      'name': 'Tomato',
      'currentPrice': 30.0,
      'stockQuantity': 50.0,
      'stockStatus': 'IN_STOCK',
    });
    expect(inStock.isInStock, isTrue);
    expect(inStock.stockStatus, 'IN_STOCK');
  });
}
