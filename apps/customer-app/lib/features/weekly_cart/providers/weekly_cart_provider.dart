import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/weekly_cart_model.dart';

class WeeklyCartProvider extends ChangeNotifier {
  final DioClient dioClient;
  final bool enableMockFallback;

  WeeklyCartProvider({required this.dioClient, this.enableMockFallback = false}) {
    if (enableMockFallback) _activeWeeklyCart = _seededWeeklyCart;
  }

  List<WeeklyCartModel> _weeklyCarts = [];
  WeeklyCartModel? _activeWeeklyCart;
  String _selectedDay = 'TUESDAY';
  bool _isLoading = false;
  String? _errorMessage;

  List<WeeklyCartModel> get weeklyCarts => List.unmodifiable(_weeklyCarts);
  WeeklyCartModel? get activeWeeklyCart => _activeWeeklyCart;
  String get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<String> daysOrder = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  void selectDay(String day) {
    _selectedDay = day.toUpperCase();
    notifyListeners();
  }

  Future<void> fetchWeeklyCarts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await dioClient.get('/weekly-carts');
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      _weeklyCarts = rawList
          .map((e) => WeeklyCartModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _activeWeeklyCart = _weeklyCarts.isNotEmpty ? _weeklyCarts.first : null;
    } catch (_) {
      if (enableMockFallback) {
        _activeWeeklyCart ??= _seededWeeklyCart;
        if (_weeklyCarts.isEmpty && _activeWeeklyCart != null) {
          _weeklyCarts = [_activeWeeklyCart!];
        }
      } else {
        _errorMessage = 'Unable to load weekly planner. Please retry.';
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateDayItems(String day, List<WeeklyCartItemModel> items) async {
    final current = _activeWeeklyCart ?? _seededWeeklyCart;
    if (!current.isModifiable) {
      _errorMessage = 'Edit limit reached (1/1). Weekly cart is locked.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await dioClient.put('/weekly-carts/${current.id}/days', data: {
        'dayOfWeek': day,
        'items': items
            .map((i) => {'productId': i.productId, 'quantity': i.quantity})
            .toList(),
      });
    } catch (_) {}

    final updatedDays = List<WeeklyCartDayModel>.from(current.days);
    final dayTotal = items.fold<double>(0.0, (s, i) => s + i.totalPrice);
    final idx = updatedDays.indexWhere((d) => d.dayOfWeek == day);
    if (idx >= 0) {
      updatedDays[idx] = WeeklyCartDayModel(
        dayOfWeek: day,
        items: items,
        dayTotal: dayTotal,
      );
    } else {
      updatedDays.add(WeeklyCartDayModel(
        dayOfWeek: day,
        items: items,
        dayTotal: dayTotal,
      ));
    }

    final weeklyTotal = updatedDays.fold<double>(0.0, (s, d) => s + d.dayTotal);
    _activeWeeklyCart = WeeklyCartModel(
      id: current.id,
      title: current.title,
      status: current.status,
      modificationCount: current.modificationCount,
      isModifiable: current.isModifiable,
      days: updatedDays,
      weeklyEstimatedTotal: weeklyTotal,
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> submitWeeklyCart() async {
    final current = _activeWeeklyCart;
    if (current == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await dioClient.post('/weekly-carts/${current.id}/submit');
      final data = res.data['data'] as Map<String, dynamic>;
      _activeWeeklyCart = WeeklyCartModel.fromJson(data);
    } catch (_) {
      _activeWeeklyCart = WeeklyCartModel(
        id: current.id,
        title: current.title,
        status: 'SUBMITTED',
        modificationCount: 0,
        isModifiable: true,
        days: current.days,
        weeklyEstimatedTotal: current.weeklyEstimatedTotal,
      );
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> modifySubmittedWeeklyCart() async {
    final current = _activeWeeklyCart;
    if (current == null) return false;

    if (current.modificationCount >= 1 || !current.isModifiable) {
      _errorMessage = 'Weekly cart modification limit reached (1/1).';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await dioClient.post('/weekly-carts/${current.id}/modify');
      final data = res.data['data'] as Map<String, dynamic>;
      _activeWeeklyCart = WeeklyCartModel.fromJson(data);
    } catch (_) {
      _activeWeeklyCart = WeeklyCartModel(
        id: current.id,
        title: current.title,
        status: 'LOCKED',
        modificationCount: 1,
        isModifiable: false,
        days: current.days,
        weeklyEstimatedTotal: current.weeklyEstimatedTotal,
      );
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  WeeklyCartDayModel? getDayPlan(String day) {
    final current = _activeWeeklyCart;
    if (current == null) return null;
    for (final d in current.days) {
      if (d.dayOfWeek == day.toUpperCase()) return d;
    }
    return null;
  }

  static final WeeklyCartModel _seededWeeklyCart = WeeklyCartModel(
    id: 'wc-week-44',
    title: 'Week 44 Kitchen Basket',
    status: 'DRAFT',
    modificationCount: 0,
    isModifiable: true,
    weeklyEstimatedTotal: 865.0,
    days: [
      const WeeklyCartDayModel(
        dayOfWeek: 'MONDAY',
        dayTotal: 190.0,
        items: [
          WeeklyCartItemModel(
            id: 'wi-mon-1',
            productId: 'prod-milk',
            productName: 'A2 Gir Cow Farm Milk',
            unit: '1L',
            quantity: 1,
            unitPrice: 85.0,
            totalPrice: 85.0,
          ),
          WeeklyCartItemModel(
            id: 'wi-mon-2',
            productId: 'prod-palak',
            productName: 'Desi Palak / Spinach',
            unit: '250g',
            quantity: 2,
            unitPrice: 22.0,
            totalPrice: 44.0,
          ),
          WeeklyCartItemModel(
            id: 'wi-mon-3',
            productId: 'prod-onion',
            productName: 'Desi Red Onions',
            unit: 'kg',
            quantity: 2,
            unitPrice: 30.5,
            totalPrice: 61.0,
          ),
        ],
      ),
      const WeeklyCartDayModel(
        dayOfWeek: 'TUESDAY',
        dayTotal: 245.0,
        items: [
          WeeklyCartItemModel(
            id: 'wi-tue-1',
            productId: 'prod-milk',
            productName: 'Pure A2 Farm Milk (1L)',
            unit: '1L',
            quantity: 1,
            unitPrice: 78.0,
            totalPrice: 78.0,
          ),
          WeeklyCartItemModel(
            id: 'wi-tue-2',
            productId: 'prod-palak',
            productName: 'Desi Palak / Spinach (250g)',
            unit: '250g',
            quantity: 1,
            unitPrice: 32.0,
            totalPrice: 32.0,
          ),
          WeeklyCartItemModel(
            id: 'wi-tue-3',
            productId: 'prod-bhindi',
            productName: 'Tender Bhindi',
            unit: '500g',
            quantity: 2,
            unitPrice: 42.5,
            totalPrice: 85.0,
          ),
          WeeklyCartItemModel(
            id: 'wi-tue-4',
            productId: 'prod-onion',
            productName: 'Desi Red Onions',
            unit: 'kg',
            quantity: 1,
            unitPrice: 50.0,
            totalPrice: 50.0,
          ),
        ],
      ),
      const WeeklyCartDayModel(
        dayOfWeek: 'WEDNESDAY',
        dayTotal: 90.0,
        items: [
          WeeklyCartItemModel(
            id: 'wi-wed-1',
            productId: 'prod-palak',
            productName: 'Coriander & Methi Bundle',
            unit: '2 bunches',
            quantity: 1,
            unitPrice: 90.0,
            totalPrice: 90.0,
          ),
        ],
      ),
      const WeeklyCartDayModel(
        dayOfWeek: 'FRIDAY',
        dayTotal: 340.0,
        items: [
          WeeklyCartItemModel(
            id: 'wi-fri-1',
            productId: 'prod-grapes',
            productName: 'Nashik Grapes & Weekend Veggies',
            unit: 'basket',
            quantity: 1,
            unitPrice: 340.0,
            totalPrice: 340.0,
          ),
        ],
      ),
    ],
  );
}
