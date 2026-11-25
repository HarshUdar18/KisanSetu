import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/features/location/providers/address_provider.dart';

void main() {
  group('Serviceability Logic Tests', () {
    test('Valid 6-digit PIN code serviceability result holds correct attributes', () {
      const result = ServiceabilityResult(
        isServiceable: true,
        serviceAreaName: 'Shivajinagar Central',
        message: 'Delivery available in Shivajinagar within 24 hours.',
      );

      expect(result.isServiceable, isTrue);
      expect(result.serviceAreaName, 'Shivajinagar Central');
      expect(result.message, contains('24 hours'));
    });

    test('Unserviceable PIN code returns false and appropriate warning message', () {
      const result = ServiceabilityResult(
        isServiceable: false,
        serviceAreaName: null,
        message: 'Delivery currently unavailable in your area.',
      );

      expect(result.isServiceable, isFalse);
      expect(result.serviceAreaName, isNull);
      expect(result.message, 'Delivery currently unavailable in your area.');
    });
  });
}
