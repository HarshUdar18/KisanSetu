import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';

class NotificationsProvider extends ChangeNotifier {
  final DioClient? dioClient;
  final bool enableMockFallback;

  NotificationsProvider({this.dioClient, this.enableMockFallback = false});

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _items.where((n) => n['read'] == false || n['isRead'] == false).length;

  Future<void> fetchNotifications() async {
    if (dioClient == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await dioClient!.get('/notifications');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      _items = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        m['read'] = m['isRead'] ?? m['read'] ?? false;
        return m;
      }).toList();
    } catch (_) {
      if (!enableMockFallback) {
        _errorMessage = 'Unable to load notifications.';
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final idx = _items.indexWhere((n) => n['id'] == id);
    if (idx >= 0) {
      _items[idx]['read'] = true;
      _items[idx]['isRead'] = true;
      notifyListeners();
    }
    try {
      if (dioClient != null) {
        await dioClient!.put('/notifications/$id/read');
      }
    } catch (_) {}
  }

  void markAllRead() {
    for (final item in _items) {
      item['read'] = true;
      item['isRead'] = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
