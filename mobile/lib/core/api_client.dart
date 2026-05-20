// Dio wrapper with interceptors
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'secure_storage.dart';
import 'logger.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl = const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8001'); // Android emulator localhost

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getIt<SecureStorage>().getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        AppLogger.info('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info('Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error('Error: ${error.response?.statusCode} ${error.message}');
        if (error.response?.statusCode == 401) {
          // Token expired – clear storage and redirect to login
          getIt<SecureStorage>().clearAll();
          // You can emit an event to force logout
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}