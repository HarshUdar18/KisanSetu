import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

export 'dio_client.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiException({
    this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode, $code: $message)';
}

class ApiClient {
  final Dio dio;
  final SecureStorageService storageService;

  ApiClient({required this.storageService})
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
            receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
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
        onError: (DioException error, handler) {
          final response = error.response;
          if (response != null) {
            final data = response.data;
            String message = 'Server error occurred';
            String code = 'API_ERROR';
            if (data is Map<String, dynamic>) {
              message = data['message'] as String? ?? message;
              code = data['code'] as String? ?? 'ERROR_${response.statusCode}';
            }
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: response,
                error: ApiException(
                  statusCode: response.statusCode,
                  code: code,
                  message: message,
                  details: data is Map<String, dynamic> ? data : null,
                ),
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return dio.delete<T>(path, data: data);
  }
}
