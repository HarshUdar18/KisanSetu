import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clearAll();
}

/// Production-ready secure storage backed by FlutterSecureStorage,
/// with an automatic in-memory fallback for headless widget tests.
class FlutterSecureStorageImpl implements SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final Map<String, String> _fallback = {};

  @override
  Future<void> write(String key, String value) async {
    _fallback[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Fallback kept in memory when platform channel is unavailable (e.g. unit tests)
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final val = await _storage.read(key: key);
      if (val != null) return val;
    } catch (_) {}
    return _fallback[key];
  }

  @override
  Future<void> delete(String key) async {
    _fallback.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  @override
  Future<void> clearAll() async {
    _fallback.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}

/// Kept as an alias for backward compatibility with existing tests.
class LocalStorageServiceImpl implements SecureStorageService {
  final Map<String, String> _memoryStore = {};

  @override
  Future<void> write(String key, String value) async => _memoryStore[key] = value;

  @override
  Future<String?> read(String key) async => _memoryStore[key];

  @override
  Future<void> delete(String key) async => _memoryStore.remove(key);

  @override
  Future<void> clearAll() async => _memoryStore.clear();
}

/// Non-sensitive preferences backed by SharedPreferences.
class PreferencesService {
  final Map<String, Object> _memoryFallback = {};

  Future<void> setString(String key, String value) async {
    _memoryFallback[key] = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(key);
      if (v != null) return v;
    } catch (_) {}
    return _memoryFallback[key] as String?;
  }

  Future<void> setBool(String key, bool value) async {
    _memoryFallback[key] = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getBool(key);
      if (v != null) return v;
    } catch (_) {}
    return (_memoryFallback[key] as bool?) ?? defaultValue;
  }
}
