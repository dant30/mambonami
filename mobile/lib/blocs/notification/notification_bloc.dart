import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetch);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<NewPushNotificationEvent>(_onNewPush);
  }

  Future<void> _onFetch(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications, unreadCount));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(MarkNotificationReadEvent event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        await notificationRepository.markAsRead([event.notificationId]);
        // Refresh list after marking read
        add(FetchNotificationsEvent());
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onMarkAllRead(MarkAllReadEvent event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final unreadIds = currentState.notifications
          .where((n) => !n.isRead)
          .map((n) => n.id)
          .toList();
      if (unreadIds.isNotEmpty) {
        try {
          await notificationRepository.markAsRead(unreadIds);
          add(FetchNotificationsEvent());
        } catch (e) {
          emit(NotificationError(e.toString()));
        }
      }
    }
  }

  void _onNewPush(NewPushNotificationEvent event, Emitter<NotificationState> emit) {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final updatedList = [event.notification, ...currentState.notifications];
      final unreadCount = updatedList.where((n) => !n.isRead).length;
      emit(NotificationLoaded(updatedList, unreadCount));
    }
  }
}