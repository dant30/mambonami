part of 'order_tracking_bloc.dart';

abstract class OrderTrackingEvent {}

class FetchOrderTracking extends OrderTrackingEvent {
  final String uuid;
  FetchOrderTracking(this.uuid);
}

class RefreshOrderTracking extends OrderTrackingEvent {}

class NotificationAffectsOrder extends OrderTrackingEvent {
  final dynamic notification; // NotificationModel
  NotificationAffectsOrder(this.notification);
}
