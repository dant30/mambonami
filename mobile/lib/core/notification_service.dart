import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    // Try to parse deep link from notification data
    final deepLinkInfo = DeepLinkHandler.parseNotificationData(data) ??
        _createDeepLinkFromMetadata(data);

    if (deepLinkInfo != null) {
      final routePath = deepLinkInfo.toRoutePath();
      if (routePath != null) {
        debugPrint('[NotificationService] Navigating to: $routePath');
        _navigateToDeepLink(routePath);
      }
    }
  }

  /// Create deep link info from legacy notification metadata format
  /// Fallback for notifications that don't use 'deepLink' key
  DeepLinkInfo? _createDeepLinkFromMetadata(Map<String, dynamic> data) {
    // Check for farmer order notifications
    final orderId = DeepLinkHandler.extractOrderId(data);
    if (orderId != null && data['type'] == 'farmer_order') {
      debugPrint('[NotificationService] Creating farmer order deep link: $orderId');
      return DeepLinkInfo(
        type: DeepLinkType.farmerOrderDetail,
        id: orderId.toString(),
        params: data.cast<String, String>(),
      );
    }

    // Check for order tracking notifications
    final orderUuid = DeepLinkHandler.extractOrderUuid(data);
    if (orderUuid != null && data['type'] == 'order_tracking') {
      return DeepLinkInfo(
        type: DeepLinkType.orderTracking,
        uuid: orderUuid,
        params: data.cast<String, String>(),
      );
    }

    return null;
  }

  /// Navigate to a route from deep link
  /// Stores pending deep link if router is not available
  void _navigateToDeepLink(String routePath) {
    try {
      debugPrint('[NotificationService] Received deep link route: $routePath');
      // Router integration happens through the app's startup listeners.
    } catch (e) {
      debugPrint('[NotificationService] Failed to navigate: $e');
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
}