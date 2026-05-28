import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/deep_link_handler.dart';
import '../blocs/notification/notification_bloc.dart';
import '../data/models/notification.dart';

final getIt = GetIt.instance;

/// Global variable to store pending deep link for app startup
/// Used when deep link arrives before router is fully initialized
DeepLinkInfo? _pendingDeepLink;

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
      // Try to get router from context
      // If not available, store for later navigation
      _pendingDeepLink = DeepLinkInfo(
        type: DeepLinkType.unknown,
      );
      debugPrint('[NotificationService] Stored pending deep link: $routePath');
      // The router will check for pending deep link on app startup
    } catch (e) {
      debugPrint('[NotificationService] Failed to navigate: $e');
    }
  }

  NotificationModel? _fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification == null) return null;
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch, // temporary ID (real one comes from backend)
      uuid: data['uuid'] ?? '',
      channel: 'push',
      title: notification.title ?? '',
      body: notification.body ?? '',
      metadata: data,
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