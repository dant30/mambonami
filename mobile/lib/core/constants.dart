// mobile/lib/core/constants.dart

import 'dart:io' show Platform;

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

String getApiBaseUrl() {
  if (kApiBaseUrl.isNotEmpty) return kApiBaseUrl;
  if (Platform.isIOS) return 'http://127.0.0.1:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

// Auth endpoints
const String kRegisterInitEndpoint = '/api/users/register/init/';
const String kRegisterVerifyEndpoint = '/api/users/register/verify/';
const String kLoginEndpoint = '/api/users/login/';
const String kProfileEndpoint = '/api/users/profile/';
const String kForgotPasswordInitEndpoint = '/api/users/password-reset/init/';
const String kForgotPasswordVerifyEndpoint = '/api/users/password-reset/verify/';
const String kRefreshTokenEndpoint = '/api/token/refresh/';

// Notification constants
const String kNotificationChannelId = 'mambonami_channel';
const String kNotificationChannelName = 'MAMBONAMI Notifications';

// Timeouts
const Duration kApiConnectTimeout = Duration(seconds: 30);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

