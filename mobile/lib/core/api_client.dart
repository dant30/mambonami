// mobile/lib/core/api_client.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'secure_storage.dart';
import 'logger.dart';
import 'constants.dart';

final getIt = GetIt.instance;

class ApiClient {
  late final Dio _dio;
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: getApiBaseUrl(),
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
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
        AppLogger.debug('Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info('Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        AppLogger.error('HTTP $statusCode: ${error.message}');

        if (statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            try {
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer ${await getIt<SecureStorage>().getAccessToken()}';
              final retryResponse = await _dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                  contentType: options.contentType,
                  extra: options.extra,
                  followRedirects: options.followRedirects,
                  listFormat: options.listFormat,
                  maxRedirects: options.maxRedirects,
                  receiveDataWhenStatusError: options.receiveDataWhenStatusError,
                  receiveTimeout: options.receiveTimeout,
                  requestEncoder: options.requestEncoder,
                  responseDecoder: options.responseDecoder,
                  responseType: options.responseType,
                  sendTimeout: options.sendTimeout,
                  validateStatus: options.validateStatus,
                ),
              );
              return handler.resolve(retryResponse);
            } catch (retryError, retryStack) {
              AppLogger.error('Retry failed after token refresh', error: retryError, stackTrace: retryStack);
            }
          }
          await getIt<SecureStorage>().clearAll();
        }

        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await getIt<SecureStorage>().getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return false;
      }

      final response = await _dio.post(
        kRefreshTokenEndpoint,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final access = response.data['access'] as String?;
        final refresh = response.data['refresh'] as String?;
        if (access != null) {
          await getIt<SecureStorage>().saveTokens(access, refresh ?? refreshToken);
          AppLogger.info('Token refresh succeeded');
          return true;
        }
      }

      AppLogger.warning('Refresh token endpoint returned ${response.statusCode}');
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('Token refresh request failed', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Dio get dio => _dio;
}