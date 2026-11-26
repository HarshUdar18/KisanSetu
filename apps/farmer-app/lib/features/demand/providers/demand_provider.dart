import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';

class DemandProvider extends ChangeNotifier {
  final DioClient? dioClient;

  DemandProvider({this.dioClient});

  List<Map<String, dynamic>> _demands = [];
  final List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get demands => List.unmodifiable(_demands);
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDemands() async {
    if (dioClient == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await dioClient!.get('/demands');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      _demands = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return {
          'id': m['id'] ?? '',
          'crop': m['productName'] ?? 'Produce',
          'qty': '${m['quantityKg'] ?? 0} kg',
          'rate': (m['targetPricePerKg'] as num?)?.toDouble() ?? 0.0,
          'total': ((m['quantityKg'] as num?)?.toDouble() ?? 0.0) *
              ((m['targetPricePerKg'] as num?)?.toDouble() ?? 0.0),
          'buyer': m['notes'] ?? 'Kisan Setu Cluster',
          'window': m['requiredByDate']?.toString() ?? '',
          'status': m['status'] ?? 'OPEN',
        };
      }).toList();
    } catch (_) {
      _errorMessage = 'Unable to load demand requests. Please retry.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> respondToDemand(String id, String action, {double? quotedRate}) async {
    final idx = _demands.indexWhere((d) => d['id'] == id);
    if (idx < 0) return;

    if (action == 'ACCEPTED' && dioClient != null) {
      try {
        await dioClient!.put('/demands/$id/accept', data: {
          'offeredPricePerKg': ?quotedRate,
        });
      } catch (_) {}
    }

    _demands[idx]['status'] = action;
    if (quotedRate != null) _demands[idx]['rate'] = quotedRate;
    notifyListeners();
  }

  void updateOrderStatus(String id, String status) {
    final idx = _orders.indexWhere((o) => o['id'] == id);
    if (idx < 0) return;
    _orders[idx]['status'] = status;
    notifyListeners();
  }
}
