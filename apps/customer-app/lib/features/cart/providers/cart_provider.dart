import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/mock_services.dart';
import '../../catalog/models/product_model.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  CartProvider({required this.dioClient, this.enableMockFallback = false});

  CartModel _cart = CartModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  String? _appliedCouponCode;
  double _couponDiscount = 0.0;
  String? _priceUpdatedNotice;

  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get appliedCouponCode => _appliedCouponCode;
  double get couponDiscount => _couponDiscount;
  String? get priceUpdatedNotice => _priceUpdatedNotice;

  double get finalPayable =>
      (_cart.estimatedTotal - _couponDiscount).clamp(0.0, double.infinity);

  double get directFarmerShare => (_cart.subtotal * 0.80);

  double quantityForProduct(String productId) {
    for (final item in _cart.items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  String? itemIdForProduct(String productId) {
    for (final item in _cart.items) {
      if (item.productId == productId) return item.id;
    }
    return null;
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.get('/cart');
      final data = response.data['data'] as Map<String, dynamic>;
      _cart = CartModel.fromJson(data);
    } catch (_) {
      // Keep local cart state if backend is offline
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addProduct(ProductModel product, {double quantity = 1.0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.post('/cart/items', data: {
        'productId': product.id,
        'quantity': quantity,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      _cart = CartModel.fromJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      if (!enableMockFallback) {
        _errorMessage = 'Unable to add item to cart. Please check your connection and retry.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Isolated test fallback only
      final existing = List<CartItemModel>.from(_cart.items);
      final idx = existing.indexWhere((i) => i.productId == product.id);
      if (idx >= 0) {
        final cur = existing[idx];
        final newQty = cur.quantity + quantity;
        existing[idx] = CartItemModel(
          id: cur.id,
          productId: cur.productId,
          productName: cur.productName,
          marathiName: cur.marathiName,
          unit: cur.unit,
          quantity: newQty,
          unitPrice: cur.unitPrice,
          totalPrice: newQty * cur.unitPrice,
        );
      } else {
        existing.add(CartItemModel(
          id: 'ci-${DateTime.now().millisecondsSinceEpoch}',
          productId: product.id,
          productName: product.name,
          marathiName: product.marathiName,
          unit: product.unit,
          quantity: quantity,
          unitPrice: product.currentPrice,
          totalPrice: quantity * product.currentPrice,
        ));
      }
      _recomputeLocalCart(existing);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> updateQuantity(String itemId, double newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(itemId);
      return;
    }
    try {
      final response = await dioClient.put('/cart/items/$itemId', data: {
        'quantity': newQuantity,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      _cart = CartModel.fromJson(data);
      notifyListeners();
      return;
    } catch (_) {
      final existing = List<CartItemModel>.from(_cart.items);
      final idx = existing.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        final cur = existing[idx];
        existing[idx] = CartItemModel(
          id: cur.id,
          productId: cur.productId,
          productName: cur.productName,
          marathiName: cur.marathiName,
          unit: cur.unit,
          quantity: newQuantity,
          unitPrice: cur.unitPrice,
          totalPrice: newQuantity * cur.unitPrice,
        );
        _recomputeLocalCart(existing);
      }
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final response = await dioClient.delete('/cart/items/$itemId');
      final data = response.data['data'] as Map<String, dynamic>;
      _cart = CartModel.fromJson(data);
      notifyListeners();
      return;
    } catch (_) {
      final existing = _cart.items.where((i) => i.id != itemId).toList();
      _recomputeLocalCart(existing);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await dioClient.delete('/cart');
    } catch (_) {}
    _cart = CartModel.empty();
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    notifyListeners();
  }

  Map<String, dynamic> applyCoupon(String code) {
    final res = MockCustomerServices.validateCoupon(code, _cart.subtotal);
    if (res['valid'] == true) {
      _appliedCouponCode = res['code'] as String;
      _couponDiscount = (res['discountAmount'] as num).toDouble();
      notifyListeners();
    }
    return res;
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _couponDiscount = 0.0;
    notifyListeners();
  }

  void dismissPriceNotice() {
    _priceUpdatedNotice = null;
    notifyListeners();
  }

  void _recomputeLocalCart(List<CartItemModel> items) {
    final subtotal = items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
    final deliveryFee = subtotal >= 299 || subtotal == 0 ? 0.0 : 40.0;
    final logisticsFee = subtotal == 0 ? 0.0 : 15.0;
    final total = subtotal + deliveryFee + logisticsFee;
    _cart = CartModel(
      id: _cart.id.isEmpty ? 'local-cart' : _cart.id,
      items: items,
      itemCount: items.length,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      logisticsFee: logisticsFee,
      taxAmount: 0.0,
      totalAmount: total,
    );
  }
}
