part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool hasMore;
  final String? nextPageUrl;

  const NotificationLoaded(
    this.notifications,
    this.unreadCount, {
    this.hasMore = false,
    this.nextPageUrl,
  });

  @override List<Object?> get props => [notifications, unreadCount, hasMore, nextPageUrl];
}
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override List<Object> get props => [message];
}