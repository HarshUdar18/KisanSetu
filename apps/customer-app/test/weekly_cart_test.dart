import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/features/weekly_cart/models/weekly_cart_model.dart';

void main() {
  group('Weekly Cart Model & Business Rules Tests', () {
    test('DRAFT weekly cart allows initial editing with modificationCount 0', () {
      final json = {
        'id': 'wc-01',
        'title': 'My Family Weekly Basket',
        'status': 'DRAFT',
        'modificationCount': 0,
        'isModifiable': true,
        'days': [],
        'weeklyEstimatedTotal': 0.0,
      };

      final cart = WeeklyCartModel.fromJson(json);

      expect(cart.status, 'DRAFT');
      expect(cart.modificationCount, 0);
      expect(cart.isModifiable, isTrue);
    });

    test('SUBMITTED weekly cart allows exactly one correction modification', () {
      final json = {
        'id': 'wc-02',
        'title': 'Weekly Organic Plan',
        'status': 'SUBMITTED',
        'modificationCount': 0,
        'isModifiable': true,
        'days': [
          {
            'dayOfWeek': 'MONDAY',
            'items': [
              {
                'id': 'wi-1',
                'productId': 'p-tom',
                'productName': 'Tomato',
                'quantity': 2.0,
                'unitPrice': 35.0,
                'totalPrice': 70.0,
              }
            ],
            'dayTotal': 70.0,
          },
          {
            'dayOfWeek': 'WEDNESDAY',
            'items': [
              {
                'id': 'wi-2',
                'productId': 'p-spin',
                'productName': 'Spinach',
                'quantity': 1.0,
                'unitPrice': 20.0,
                'totalPrice': 20.0,
              }
            ],
            'dayTotal': 20.0,
          }
        ],
        'weeklyEstimatedTotal': 90.0,
      };

      final cart = WeeklyCartModel.fromJson(json);

      expect(cart.status, 'SUBMITTED');
      expect(cart.modificationCount, 0);
      expect(cart.isModifiable, isTrue);
      expect(cart.days.length, 2);
      expect(cart.weeklyEstimatedTotal, 90.0);
    });

    test('LOCKED weekly cart rejects further modification (modificationCount = 1)', () {
      final json = {
        'id': 'wc-03',
        'title': 'Finalized Weekly Plan',
        'status': 'LOCKED',
        'modificationCount': 1,
        'isModifiable': false,
        'days': [],
        'weeklyEstimatedTotal': 150.0,
      };

      final cart = WeeklyCartModel.fromJson(json);

      expect(cart.status, 'LOCKED');
      expect(cart.modificationCount, 1);
      expect(cart.isModifiable, isFalse);
    });
  });
}
