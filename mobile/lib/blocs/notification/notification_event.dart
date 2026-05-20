part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkNotificationReadEvent extends NotificationEvent {
  final int notificationId;
  const MarkNotificationReadEvent(this.notificationId);
  @override List<Object> get props => [notificationId];
}

class MarkAllReadEvent extends NotificationEvent {}

class NewPushNotificationEvent extends NotificationEvent {
  final NotificationModel notification;
  const NewPushNotificationEvent(this.notification);
  @override List<Object> get props => [notification];
}