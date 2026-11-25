class AppFailure {
  final String message;
  final String? code;

  AppFailure({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  NetworkFailure([String message = 'Network connection failed. Ensure backend is running.'])
      : super(message: message, code: 'NETWORK_ERROR');
}

class AuthFailure extends AppFailure {
  AuthFailure(String message, [String? code]) : super(message: message, code: code ?? 'AUTH_ERROR');
}
