import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  final Dio dio;
  final SecureStorageService storageService;
  Completer<String?>? _refreshCompleter;

  DioClient({
    required this.storageService,
    Duration connectTimeout = const Duration(seconds: AppConstants.connectTimeoutSeconds),
    Duration receiveTimeout = const Duration(seconds: AppConstants.receiveTimeoutSeconds),
  }) : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.read(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final req = error.requestOptions;
          if (error.response?.statusCode == 401 &&
              !req.path.contains('/auth/login') &&
              !req.path.contains('/auth/refresh') &&
              req.extra['retried'] != true) {
            final newToken = await _refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              req.headers['Authorization'] = 'Bearer $newToken';
              req.extra['retried'] = true;
              try {
                final cloned = await dio.fetch(req);
                return handler.resolve(cloned);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<String?>();
    try {
      final refreshToken = await storageService.read(AppConstants.refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(null);
        return null;
      }
      final res = await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
          .post('/auth/refresh', data: {'refreshToken': refreshToken});
      final data = res.data['data'] as Map<String, dynamic>?;
      final newToken = data?['token'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        await storageService.write(AppConstants.tokenKey, newToken);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await storageService.write(AppConstants.refreshTokenKey, newRefresh);
        }
        _refreshCompleter!.complete(newToken);
        return newToken;
      }
      await storageService.delete(AppConstants.tokenKey);
      await storageService.delete(AppConstants.refreshTokenKey);
      _refreshCompleter!.complete(null);
      return null;
    } catch (_) {
      await storageService.delete(AppConstants.tokenKey);
      await storageService.delete(AppConstants.refreshTokenKey);
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
