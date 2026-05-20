import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../blocs/notification/notification_bloc.dart';
import '../data/models/notification.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Request permissions
    await _fcm.requestPermission();
    
    // Get FCM token and send to backend
    final token = await _fcm.getToken();
    if (token != null) {
      // TODO: Send token to your backend (store in user's fcm_token field)
      print('FCM Token: $token');
    }

    // Setup local notifications for when app is in foreground
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(settings);

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
    final notification = _fromRemoteMessage(message);
    if (notification != null) {
      // Add to BLoC and navigate to relevant screen based on metadata
      final bloc = getIt<NotificationBloc>();
      bloc.add(NewPushNotificationEvent(notification));
      // Optionally navigate based on metadata['order_id'], etc.
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
      'mambonami_channel',
      'MAMBONAMI Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      notification.id,
      notification.title,
      notification.body,
      details,
    );
  }
}