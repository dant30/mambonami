import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/deep_link_handler.dart';
import '../blocs/notification/notification_bloc.dart';
import '../data/models/notification.dart';

final getIt = GetIt.instance;

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  String? _pendingRoute;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _fcm.requestPermission();

      // Get FCM token and send to backend
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await saveFCMToken(token);
      }

      // Setup local notifications for when app is in foreground
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _localNotifications.initialize(settings: settings);

      // Listen to messages while app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle when app is opened from a terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Handle when app is in background and user taps notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      _resolvePendingDeepLink();
      _isInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('NotificationService initialization failed: $error');
      debugPrint(stackTrace.toString());
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _fromRemoteMessage(message);
    if (notification != null) {
      // Show local notification
      _showLocalNotification(notification);
      // Add to BLoC
      final bloc = getIt<NotificationBloc>();
      bloc.add(NewPushNotificationEvent(notification));
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('[NotificationService] Handling message from: ${message.from}');
    final notification = _fromRemoteMessage(message);
    if (notification != null) {
      // Add to BLoC
      final bloc = getIt<NotificationBloc>();
      bloc.add(NewPushNotificationEvent(notification));
      
      // Handle deep link if present
      _handleDeepLink(message.data);
    }
  }

  /// Handle deep link navigation from notification data
  /// Stores pending deep link if router is not yet available
  void _handleDeepLink(Map<String, dynamic> data) {
    debugPrint('[NotificationService] Processing deep link from notification');

    final deepLinkInfo = DeepLinkHandler.parseNotificationPayload(data);
    if (deepLinkInfo != null) {
      final routePath = deepLinkInfo.toRoutePath();
      if (routePath != null) {
        debugPrint('[NotificationService] Navigating to: $routePath');
        _navigateToDeepLink(routePath);
      }
    }
  }

  void _navigateToDeepLink(String routePath) {
    try {
      debugPrint('[NotificationService] Received deep link route: $routePath');
      if (getIt.isRegistered<GoRouter>()) {
        getIt<GoRouter>().go(routePath);
        return;
      }
      _pendingRoute = routePath;
    } catch (e) {
      debugPrint('[NotificationService] Failed to navigate: $e');
    }
  }

  void _resolvePendingDeepLink() {
    if (_pendingRoute != null && getIt.isRegistered<GoRouter>()) {
      try {
        getIt<GoRouter>().go(_pendingRoute!);
        _pendingRoute = null;
      } catch (e) {
        debugPrint('[NotificationService] Failed to resolve pending deep link: $e');
      }
    }
  }

  Future<void> saveFCMToken(String token) async {
    try {
      await getIt<ApiClient>().dio.post(
        '/api/notifications/fcm-token/',
        data: {
          'token': token,
        },
      );
      debugPrint('[NotificationService] FCM token saved successfully');
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        debugPrint('[NotificationService] FCM token endpoint not available on backend; skipping');
      } else {
        debugPrint('[NotificationService] Failed to save FCM token: $error');
      }
    } catch (error, stackTrace) {
      debugPrint('[NotificationService] Failed to save FCM token: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Map<String, String> _stringMetadata(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  String _notificationIdFromData(Map<String, dynamic> data) {
    final uuid = data['uuid'];
    if (uuid is String && uuid.isNotEmpty) {
      return uuid;
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  NotificationModel? _fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification == null) return null;
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      uuid: _notificationIdFromData(data),
      channel: 'push',
      title: notification.title ?? '',
      body: notification.body ?? '',
      metadata: _stringMetadata(data),
      status: 'sent',
      createdAt: DateTime.now(),
      readAt: null,
    );
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const androidDetails = AndroidNotificationDetails(
      kNotificationChannelId,
      kNotificationChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }

  /// Returns the current notification permission settings for the device.
  /// Uses Firebase Messaging platform API.
  Future<NotificationSettings> getPermissionSettings() async {
    try {
      return await _fcm.getNotificationSettings();
    } catch (e) {
      rethrow;
    }
  }

  /// Convenience helper to indicate whether notifications are effectively enabled.
  Future<bool> isPermissionGranted() async {
    try {
      final settings = await getPermissionSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      return false;
    }
  }
}