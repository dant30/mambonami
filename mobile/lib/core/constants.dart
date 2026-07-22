// mobile/lib/core/constants.dart

import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

String getApiBaseUrl() {
  if (dotenv.isInitialized) {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
  }
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
const String kProfileAvatarEndpoint = '/api/users/profile/avatar/';
const String kForgotPasswordInitEndpoint = '/api/users/password-reset/init/';
const String kForgotPasswordVerifyEndpoint = '/api/users/password-reset/verify/';
const String kRefreshTokenEndpoint = '/api/token/refresh/';
const String kPasswordChangeEndpoint = '/api/users/password-change/';

// Logistics endpoints
const String kAvailableOrdersEndpoint = '/api/logistics/orders/available/';
const String kMyTripsEndpoint = '/api/logistics/my-trips/';
const String kTripDetailEndpoint = '/api/logistics/my-trips/';
const String kTripAssignEndpoint = '/api/logistics/trips/';
const String kTripPickupEndpoint = '/api/logistics/trips/';
const String kTripStartPickupNavEndpoint = '/api/logistics/trips/';
const String kTripArrivePickupEndpoint = '/api/logistics/trips/';
const String kTripStartDeliveryNavEndpoint = '/api/logistics/trips/';
const String kTripArriveDeliveryEndpoint = '/api/logistics/trips/';
const String kTripGenerateOtpEndpoint = '/api/logistics/trips/';
const String kTripVerifyOtpEndpoint = '/api/logistics/trips/';
const String kTripLocationEndpoint = '/api/logistics/my-trips/';
const String kTripMediaEndpoint = '/api/logistics/my-trips/';
const String kTransportPayoutSummaryEndpoint = '/api/payouts/summary/';

// Notification constants
const String kNotificationChannelId = 'mambonami_channel';
const String kNotificationChannelName = 'MAMBONAMI Notifications';

// Timeouts
const Duration kApiConnectTimeout = Duration(seconds: 30);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

// Local cache keys
const String kThemeModeKey = 'theme_mode';
const String kNotificationsEnabledKey = 'notifications_enabled';
const String kOrderUpdatesEnabledKey = 'order_updates_enabled';
const String kAppLocaleKey = 'app_locale';
const String kCachedProfileKey = 'cached_user_profile';
const String kUserTable = 'users';
const String kProductTable = 'products';
const String kCartItemTable = 'cart_items';
const String kAddressTable = 'saved_addresses';
// Product cache TTL
const Duration kProductCacheTTL = Duration(hours: 6);

