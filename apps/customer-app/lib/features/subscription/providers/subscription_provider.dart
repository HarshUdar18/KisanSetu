import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/subscription_model.dart';

class SubscriptionProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  SubscriptionProvider({required this.dioClient, this.enableMockFallback = false}) {
    if (enableMockFallback) _subscriptions = _seededSubscriptions;
  }

  List<SubscriptionModel> _subscriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubscriptionModel> get subscriptions => List.unmodifiable(_subscriptions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SubscriptionModel? getById(String id) {
    for (final s in _subscriptions) {
      if (s.id == id) return s;
    }
    return _subscriptions.isNotEmpty ? _subscriptions.first : null;
  }

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.get('/subscriptions');
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      _subscriptions = rawList
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      if (enableMockFallback) {
        if (_subscriptions.isEmpty) _subscriptions = _seededSubscriptions;
      } else {
        _errorMessage = 'Unable to load subscriptions. Please retry.';
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createSubscription({
    required String title,
    required String frequency,
    required String addressId,
    required double totalPerCycle,
    String? weeklyCartId,
    String? deliveryPreferences,
  }) async {
    _isLoading = true;
    notifyListeners();
    final startDate =
        DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T').first;
    try {
      await dioClient.post('/subscriptions', data: {
        'weeklyCartId': ?weeklyCartId,
        'addressId': addressId,
        'frequency': frequency,
        'startDate': startDate,
        'deliveryPreferences': ?deliveryPreferences,
      });
    } catch (_) {}

    _subscriptions.insert(
      0,
      SubscriptionModel(
        id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
        weeklyCartId: weeklyCartId ?? 'wc-custom',
        frequency: frequency,
        startDate: 'Tomorrow, 6:30 AM',
        status: 'ACTIVE',
        deliveryPreferences:
            deliveryPreferences ?? 'Morning Harvest (6:00 AM - 8:00 AM)',
        items: [
          SubscriptionItemModel(
            id: 'si-new',
            productId: 'prod-milk',
            productName: title,
            unit: 'basket',
            dayOfWeek: 'MONDAY',
            quantity: 1,
            currentPrice: totalPerCycle,
          ),
        ],
      ),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void pauseSubscription(String id, {String? resumeDate}) {
    _updateStatus(id, 'PAUSED', nextDate: resumeDate ?? 'Paused until resumed');
  }

  void resumeSubscription(String id) {
    _updateStatus(id, 'ACTIVE', nextDate: 'Tomorrow, 6:30 AM');
  }

  void cancelSubscription(String id) {
    _updateStatus(id, 'CANCELLED', nextDate: 'Cancelled');
  }

  void updateSchedule(String id, String newFrequency, String newSlot) {
    final idx = _subscriptions.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final cur = _subscriptions[idx];
    _subscriptions[idx] = SubscriptionModel(
      id: cur.id,
      weeklyCartId: cur.weeklyCartId,
      frequency: newFrequency,
      startDate: cur.startDate,
      status: cur.status,
      deliveryPreferences: newSlot,
      address: cur.address,
      items: cur.items,
    );
    notifyListeners();
  }

  void _updateStatus(String id, String status, {String? nextDate}) {
    final idx = _subscriptions.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final cur = _subscriptions[idx];
    _subscriptions[idx] = SubscriptionModel(
      id: cur.id,
      weeklyCartId: cur.weeklyCartId,
      frequency: cur.frequency,
      startDate: nextDate ?? cur.startDate,
      status: status,
      deliveryPreferences: cur.deliveryPreferences,
      address: cur.address,
      items: cur.items,
    );
    notifyListeners();
  }

  static final List<SubscriptionModel> _seededSubscriptions = [
    const SubscriptionModel(
      id: 'sub-1',
      weeklyCartId: 'wc-milk',
      frequency: 'DAILY',
      startDate: 'Tomorrow, 6:30 AM',
      status: 'ACTIVE',
      deliveryPreferences: 'Leave at doorstep • Glass bottle return',
      items: [
        SubscriptionItemModel(
          id: 'si-1',
          productId: 'prod-milk',
          productName: 'Pure A2 Gir Cow Milk (1L) + Fresh Greens',
          unit: '1L + 250g',
          dayOfWeek: 'MONDAY',
          quantity: 1,
          currentPrice: 117.0,
        ),
      ],
    ),
    const SubscriptionModel(
      id: 'sub-2',
      weeklyCartId: 'wc-family',
      frequency: 'WEEKLY',
      startDate: 'Saturday, 7:00 AM',
      status: 'ACTIVE',
      deliveryPreferences: 'Zero-plastic cornstarch bag',
      items: [
        SubscriptionItemModel(
          id: 'si-2',
          productId: 'prod-onion',
          productName: 'Family Weekly Organic Veggie Box',
          unit: '5 kg',
          dayOfWeek: 'SATURDAY',
          quantity: 1,
          currentPrice: 540.0,
        ),
      ],
    ),
  ];
}
