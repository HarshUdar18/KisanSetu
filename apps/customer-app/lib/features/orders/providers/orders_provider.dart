import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../cart/models/cart_model.dart';
import '../models/order_model.dart';
import '../models/tracking_model.dart';

class OrdersProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  OrdersProvider({required this.dioClient, this.enableMockFallback = false}) {
    if (enableMockFallback) _orders = _seededOrders;
  }

  List<OrderModel> _orders = [];
  OrderTrackingTimelineModel? _currentTracking;
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  OrderTrackingTimelineModel? get currentTracking => _currentTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderModel? getById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return _orders.isNotEmpty ? _orders.first : null;
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.get('/orders');
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      _orders = rawList
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      if (enableMockFallback) {
        if (_orders.isEmpty) _orders = _seededOrders;
      } else {
        _errorMessage = 'Unable to load orders. Please retry.';
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> checkout({
    required String addressId,
    required String deliveryDate,
    required String deliverySlot,
    required CartModel cart,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dioClient.post(
        '/orders/checkout',
        data: {
          'addressId': addressId,
          'deliveryDate': deliveryDate,
          'deliverySlot': deliverySlot,
          if (notes != null && notes.isNotEmpty) 'deliveryNotes': notes,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final order = OrderModel.fromJson(data);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (_) {
      final order = OrderModel(
        id: 'KS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        orderNumber: 'KS-2045',
        orderStatus: 'PENDING_PAYMENT',
        paymentStatus: 'PENDING',
        deliveryDate: deliveryDate,
        deliverySlot: deliverySlot,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        logisticsFee: cart.logisticsFee,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: cart.estimatedTotal,
        createdAt: DateTime.now().toIso8601String(),
        items: cart.items
            .map(
              (i) => OrderItemModel(
                id: i.id,
                productId: i.productId,
                productName: i.productName,
                unit: i.unit,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                totalPrice: i.totalPrice,
              ),
            )
            .toList(),
      );
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    }
  }

  Future<bool> processAndVerifyPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required bool simulateSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await dioClient.post(
        '/payments',
        data: {
          'orderId': orderId,
          'paymentMethod': paymentMethod,
          'simulateSuccess': simulateSuccess,
        },
      );
    } catch (_) {}

    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final cur = _orders[idx];
      _orders[idx] = OrderModel(
        id: cur.id,
        orderNumber: cur.orderNumber,
        orderStatus: simulateSuccess ? 'CONFIRMED' : 'PENDING_PAYMENT',
        paymentStatus: simulateSuccess ? 'PAID' : 'FAILED',
        deliveryDate: cur.deliveryDate,
        deliverySlot: cur.deliverySlot,
        subtotal: cur.subtotal,
        deliveryFee: cur.deliveryFee,
        logisticsFee: cur.logisticsFee,
        taxAmount: cur.taxAmount,
        discountAmount: cur.discountAmount,
        totalAmount: cur.totalAmount,
        createdAt: cur.createdAt,
        items: cur.items,
      );
    }
    _isLoading = false;
    if (!simulateSuccess) {
      _errorMessage =
          'Payment verification failed. Please retry or choose another UPI app.';
    }
    notifyListeners();
    return simulateSuccess;
  }

  Future<void> fetchTracking(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await dioClient.get('/orders/$orderId/tracking');
      final data = response.data['data'] as Map<String, dynamic>;
      _currentTracking = OrderTrackingTimelineModel.fromJson(data);
    } catch (_) {
      _currentTracking = _seededTracking(orderId);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> devAdvanceTracking(String orderId) async {
    try {
      final response = await dioClient.post(
        '/orders/$orderId/tracking/dev-advance',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      _currentTracking = OrderTrackingTimelineModel.fromJson(data);
      notifyListeners();
      return;
    } catch (_) {
      final cur = _currentTracking ?? _seededTracking(orderId);
      final idx = cur.events.indexWhere((m) => !m.isCompleted);
      if (idx >= 0) {
        final updated = List<TrackingEventModel>.from(cur.events);
        final m = updated[idx];
        updated[idx] = TrackingEventModel(
          id: m.id,
          status: m.status,
          title: m.title,
          description: m.description,
          displayOrder: m.displayOrder,
          isCompleted: true,
          occurredAt: 'Just now',
        );
        _currentTracking = OrderTrackingTimelineModel(
          orderId: cur.orderId,
          orderNumber: cur.orderNumber,
          currentStatus: m.status,
          events: updated,
        );
        notifyListeners();
      }
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await dioClient.post('/orders/$orderId/cancel', data: {'reason': reason});
    } catch (_) {
      if (!enableMockFallback) {
        _errorMessage = 'Unable to cancel order right now. Please retry.';
        notifyListeners();
        return;
      }
    }
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    final cur = _orders[idx];
    _orders[idx] = OrderModel(
      id: cur.id,
      orderNumber: cur.orderNumber,
      orderStatus: 'CANCELLED',
      paymentStatus: cur.paymentStatus == 'PAID'
          ? 'REFUND_INITIATED'
          : cur.paymentStatus,
      deliveryDate: cur.deliveryDate,
      deliverySlot: cur.deliverySlot,
      subtotal: cur.subtotal,
      deliveryFee: cur.deliveryFee,
      logisticsFee: cur.logisticsFee,
      taxAmount: cur.taxAmount,
      discountAmount: cur.discountAmount,
      totalAmount: cur.totalAmount,
      createdAt: cur.createdAt,
      items: cur.items,
    );
    notifyListeners();
  }

  static final List<OrderModel> _seededOrders = [
    const OrderModel(
      id: 'ord-2041',
      orderNumber: 'KS-2041',
      orderStatus: 'OUT_FOR_DELIVERY',
      paymentStatus: 'PAID',
      deliveryDate: 'Tomorrow, 6:45 AM',
      deliverySlot: 'Morning Harvest (6:00 AM - 8:00 AM)',
      subtotal: 565.0,
      deliveryFee: 0.0,
      logisticsFee: 15.0,
      taxAmount: 0.0,
      discountAmount: 50.0,
      totalAmount: 530.0,
      createdAt: '2026-11-24T06:30:00Z',
      items: [
        OrderItemModel(
          id: 'oi-1',
          productId: 'prod-onion',
          productName: 'Desi Red Onions (कांदा)',
          unit: '1 kg',
          quantity: 2,
          unitPrice: 28.0,
          totalPrice: 56.0,
        ),
        OrderItemModel(
          id: 'oi-2',
          productId: 'prod-rice',
          productName: 'Indrayani Aromatic Rice',
          unit: '5 kg bag',
          quantity: 1,
          unitPrice: 380.0,
          totalPrice: 380.0,
        ),
        OrderItemModel(
          id: 'oi-3',
          productId: 'prod-milk',
          productName: 'A2 Gir Cow Farm Milk',
          unit: '1L Glass Bottle',
          quantity: 1,
          unitPrice: 85.0,
          totalPrice: 85.0,
        ),
      ],
    ),
    const OrderModel(
      id: 'ord-1988',
      orderNumber: 'KS-1988',
      orderStatus: 'DELIVERED',
      paymentStatus: 'PAID',
      deliveryDate: '20 Nov 2026',
      deliverySlot: 'Morning Harvest (6:00 AM - 8:00 AM)',
      subtotal: 240.0,
      deliveryFee: 0.0,
      logisticsFee: 15.0,
      taxAmount: 0.0,
      discountAmount: 0.0,
      totalAmount: 255.0,
      createdAt: '2026-11-19T18:10:00Z',
      items: [
        OrderItemModel(
          id: 'oi-4',
          productId: 'prod-palak',
          productName: 'Fresh Organic Spinach / Palak',
          unit: '250g bunch',
          quantity: 3,
          unitPrice: 22.0,
          totalPrice: 66.0,
        ),
      ],
    ),
  ];

  static OrderTrackingTimelineModel _seededTracking(String orderId) {
    return OrderTrackingTimelineModel(
      orderId: orderId,
      orderNumber: orderId.startsWith('KS') ? orderId : 'KS-2041',
      currentStatus: 'OUT_FOR_DELIVERY',
      events: const [
        TrackingEventModel(
          id: 'te-1',
          status: 'ORDER_CONFIRMED',
          title: 'Order Confirmed',
          description: 'Harvest demand locked with Niphad & Baramati FPOs',
          displayOrder: 1,
          isCompleted: true,
          occurredAt: '08:15 PM',
        ),
        TrackingEventModel(
          id: 'te-2',
          status: 'FARMER_PREPARING',
          title: 'Farmer Preparing Produce',
          description: 'Dawn harvest picked at 4:30 AM by Ramesh Shinde',
          displayOrder: 2,
          isCompleted: true,
          occurredAt: '04:30 AM',
        ),
        TrackingEventModel(
          id: 'te-3',
          status: 'COLLECTION_POINT',
          title: 'Collection Point',
          description: 'Crates weighed and logged at Mulshi Village Hub',
          displayOrder: 3,
          isCompleted: true,
          occurredAt: '05:10 AM',
        ),
        TrackingEventModel(
          id: 'te-4',
          status: 'QUALITY_INSPECTION',
          title: 'Quality Inspection',
          description: 'Grade A freshness & residue-free batch verified',
          displayOrder: 4,
          isCompleted: true,
          occurredAt: '05:25 AM',
        ),
        TrackingEventModel(
          id: 'te-5',
          status: 'WAREHOUSE',
          title: 'Warehouse',
          description: 'Sorted into zero-plastic cornstarch bags',
          displayOrder: 5,
          isCompleted: true,
          occurredAt: '05:45 AM',
        ),
        TrackingEventModel(
          id: 'te-6',
          status: 'HUB',
          title: 'Regional Hub',
          description: 'Arrived at Pune West Cold-Chain Dispatch',
          displayOrder: 6,
          isCompleted: true,
          occurredAt: '06:05 AM',
        ),
        TrackingEventModel(
          id: 'te-7',
          status: 'DELIVERY_STATION',
          title: 'Delivery Station',
          description: 'Checked in at Kothrud Micro-Station',
          displayOrder: 7,
          isCompleted: true,
          occurredAt: '06:20 AM',
        ),
        TrackingEventModel(
          id: 'te-8',
          status: 'DELIVERY_PARTNER_ASSIGNED',
          title: 'Delivery Partner Assigned',
          description: 'Vikram Kadam (EV Van MH-12-KS-4410) assigned',
          displayOrder: 8,
          isCompleted: true,
          occurredAt: '06:25 AM',
        ),
        TrackingEventModel(
          id: 'te-9',
          status: 'OUT_FOR_DELIVERY',
          title: 'Out for Delivery',
          description: 'On the way to Kothrud, Pune 411038',
          displayOrder: 9,
          isCompleted: false,
          occurredAt: 'ETA 6:45 AM',
        ),
      ],
    );
  }
}
