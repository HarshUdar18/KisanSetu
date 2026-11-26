import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_farmer_app/core/location/kisan_osm_map_picker.dart';
import 'package:kisansetu_farmer_app/core/location/location_models.dart';

void main() {
  test('LocationCoordinateValidator validates farm coordinates', () {
    expect(LocationCoordinateValidator.isValid(18.5011, 73.5130), isTrue);
    expect(LocationCoordinateValidator.isValid(-95.0, 73.5130), isFalse);
    expect(LocationCoordinateValidator.isValid(18.5011, 200.0), isFalse);
  });

  test('FarmerFarmModel parses backend farm payload', () {
    final farm = FarmerFarmModel.fromJson({
      'id': '01950000-0000-7000-8000-000000000001',
      'farmName': 'Mulshi Orchard',
      'village': 'Mulshi',
      'district': 'Pune',
      'state': 'Maharashtra',
      'latitude': 18.5011,
      'longitude': 73.5130,
      'landArea': 3.5,
      'landUnit': 'acre',
    });
    expect(farm.farmName, 'Mulshi Orchard');
    expect(farm.latitude, 18.5011);
    expect(farm.landArea, 3.5);
  });

  test('NearbyHubModel parses Admin-managed collection point payload', () {
    final hub = NearbyHubModel.fromJson({
      'hubId': '01950000-0000-7000-8000-000000000099',
      'hubCode': 'HUB-PMC-01',
      'hubName': 'Shivajinagar Collection Point',
      'hubType': 'COLLECTION_HUB',
      'address': 'JM Road, Shivajinagar',
      'district': 'Pune',
      'state': 'Maharashtra',
      'pincode': '411005',
      'latitude': 18.5308,
      'longitude': 73.8475,
      'distanceMeters': 2400.0,
      'distanceType': 'POSTGIS_GEOGRAPHY',
    });
    expect(hub.hubName, 'Shivajinagar Collection Point');
    expect(hub.distanceKm, 2.4);
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
}
