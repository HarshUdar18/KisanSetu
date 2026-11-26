import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';

class SettlementsProvider extends ChangeNotifier {
  final DioClient? dioClient;

  SettlementsProvider({this.dioClient});

  List<Map<String, dynamic>> _ledger = [];
  final List<Map<String, dynamic>> _storeCart = [];
  double _weeklyBalance = 0.0;
  double _walletBalance = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get ledger => List.unmodifiable(_ledger);
  List<Map<String, dynamic>> get storeCart => List.unmodifiable(_storeCart);
  double get weeklyBalance => _weeklyBalance;
  double get walletBalance => _walletBalance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get storeCartTotal => _storeCart.fold<double>(
        0.0,
        (s, i) => s + ((i['subsidyPrice'] as num).toDouble() * (i['qty'] as int)),
      );

  Future<void> fetchSettlements() async {
    if (dioClient == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await dioClient!.get('/settlements');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      double pendingTotal = 0.0;
      _ledger = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final net = (m['netAmount'] as num?)?.toDouble() ?? 0.0;
        final status = (m['status'] as String?) ?? 'PENDING';
        if (status == 'PENDING' || status == 'AUTHORIZED') {
          pendingTotal += net;
        }
        return {
          'id': m['transactionReference'] ?? m['id'] ?? '',
          'title': 'Harvest Settlement (${m['bankAccountMasked'] ?? 'Bank DBT'})',
          'subtitle': m['remarks'] ?? 'Direct Bank Transfer',
          'amount': net,
          'isCredit': true,
          'status': status,
          'date': m['createdAt']?.toString() ?? '',
        };
      }).toList();
      _weeklyBalance = pendingTotal;
    } catch (_) {
      _errorMessage = 'Unable to load settlements. Please retry.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void addToStoreCart(Map<String, dynamic> product) {
    final idx = _storeCart.indexWhere((i) => i['id'] == product['id']);
    if (idx >= 0) {
      _storeCart[idx]['qty'] = (_storeCart[idx]['qty'] as int) + 1;
    } else {
      _storeCart.add({...product, 'qty': 1});
    }
    notifyListeners();
  }

  void clearStoreCart() {
    _storeCart.clear();
    notifyListeners();
  }

  void requestWalletWithdrawal(double amount) {
    if (amount <= 0 || amount > _walletBalance) return;
    _walletBalance -= amount;
    _ledger.insert(0, {
      'id': 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'title': 'Instant Bank Transfer Request',
      'subtitle': 'Initiated to linked bank account • Pending gateway confirmation',
      'amount': -amount,
      'isCredit': false,
      'status': 'PROCESSING',
      'date': 'Just now',
    });
    notifyListeners();
  }
}
