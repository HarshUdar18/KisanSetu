import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  final Dio dio;
  final SecureStorageService storageService;

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
      ),
    );
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
