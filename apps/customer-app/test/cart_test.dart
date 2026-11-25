import 'package:flutter_test/flutter_test.dart';
import 'package:kisansetu_customer_app/features/cart/models/cart_model.dart';

void main() {
  group('Cart Model Tests', () {
    test('CartModel.empty() initialises with zero values and empty items', () {
      final cart = CartModel.empty();

      expect(cart.id, isEmpty);
      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.totalAmount, 0.0);
      expect(cart.estimatedTotal, 0.0);
    });

    test('CartItemModel parsed from JSON correctly computes values', () {
      final json = {
        'id': 'item-01',
        'productId': 'prod-tomato',
        'productName': 'Desi Tomato',
        'marathiName': 'टोमॅटो',
        'unit': 'kg',
        'quantity': 2.5,
        'unitPrice': 35.0,
        'totalPrice': 87.5,
      };

      final item = CartItemModel.fromJson(json);

      expect(item.id, 'item-01');
      expect(item.productId, 'prod-tomato');
      expect(item.productName, 'Desi Tomato');
      expect(item.marathiName, 'टोमॅटो');
      expect(item.unit, 'kg');
      expect(item.quantity, 2.5);
      expect(item.unitPrice, 35.0);
      expect(item.totalPrice, 87.5);
    });

    test('CartModel parsed from JSON calculates estimated total including fees', () {
      final json = {
        'id': 'cart-123',
        'items': [
          {
            'id': 'i1',
            'productId': 'p1',
            'productName': 'Desi Tomato',
            'quantity': 2.0,
            'unitPrice': 35.0,
            'totalPrice': 70.0,
          },
          {
            'id': 'i2',
            'productId': 'p2',
            'productName': 'Onion',
            'quantity': 3.0,
            'unitPrice': 25.0,
            'totalPrice': 75.0,
          }
        ],
        'itemCount': 2,
        'subtotal': 145.0,
        'deliveryFee': 30.0,
        'logisticsFee': 10.0,
        'taxAmount': 0.0,
        'totalAmount': 185.0,
      };

      final cart = CartModel.fromJson(json);

      expect(cart.items.length, 2);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 145.0);
      expect(cart.deliveryFee, 30.0);
      expect(cart.logisticsFee, 10.0);
      expect(cart.totalAmount, 185.0);
      expect(cart.estimatedTotal, 185.0);
    });
  });
}
