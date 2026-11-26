import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/storage_service.dart';
import '../constants/app_constants.dart';

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
          // In debug Android mode, if 127.0.0.1:8080 isn't reverse-forwarded (e.g. emulator),
          // fall back seamlessly to 10.0.2.2:8080 when connection fails.
          if (kDebugMode &&
              defaultTargetPlatform == TargetPlatform.android &&
              error.type == DioExceptionType.connectionError &&
              dio.options.baseUrl.contains('127.0.0.1:8080') &&
              req.extra['emulatorFallbackTried'] != true) {
            req.extra['emulatorFallbackTried'] = true;
            const emulatorBase = 'http://10.0.2.2:8080/api/v1';
            try {
              final probe = await Dio(
                BaseOptions(
                  baseUrl: emulatorBase,
                  connectTimeout: const Duration(milliseconds: 1500),
                  receiveTimeout: const Duration(seconds: 5),
                ),
              ).fetch(req.copyWith(baseUrl: emulatorBase));
              dio.options.baseUrl = emulatorBase;
              return handler.resolve(probe);
            } catch (_) {}
          }
          if (error.response?.statusCode == 401 &&
              !req.path.contains('/auth/login') &&
              !req.path.contains('/auth/refresh') &&
              !req.path.contains('/auth/request-otp') &&
              !req.path.contains('/auth/send-otp') &&
              !req.path.contains('/auth/verify-otp') &&
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
      final res = await Dio(BaseOptions(baseUrl: dio.options.baseUrl))
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
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await storageService.delete(AppConstants.tokenKey);
        await storageService.delete(AppConstants.refreshTokenKey);
      }
      _refreshCompleter!.complete(null);
      return null;
    } catch (_) {
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

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
