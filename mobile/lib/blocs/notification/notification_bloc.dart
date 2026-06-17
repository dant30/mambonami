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
    on<MarkNotificationReadEvent>(_onMarkReadOptimistic);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<NewPushNotificationEvent>(_onNewPush);
  }

  NotificationModel _withReadState(NotificationModel notification) {
    return NotificationModel(
      id: notification.id,
      uuid: notification.uuid,
      channel: notification.channel,
      title: notification.title,
      body: notification.body,
      metadata: notification.metadata,
      status: 'read',
      createdAt: notification.createdAt,
      readAt: notification.readAt ?? DateTime.now(),
    );
  }

  NotificationLoaded _buildLoadedState(
    List<NotificationModel> notifications, {
    required bool hasMore,
    required String? nextPageUrl,
  }) {
    final unreadCount = notifications.where((notification) => !notification.isRead).length;
    return NotificationLoaded(
      notifications,
      unreadCount,
      hasMore: hasMore,
      nextPageUrl: nextPageUrl,
    );
  }

  Future<void> _onFetch(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final dto = await notificationRepository.getNotifications();
      emit(_buildLoadedState(
        dto.notifications,
        hasMore: dto.hasMore,
        nextPageUrl: dto.next,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkReadOptimistic(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      // Optimistic update: mark locally first
      final updated = currentState.notifications
          .map((notification) => notification.id == event.notificationId
              ? _withReadState(notification)
              : notification)
          .toList();

      emit(_buildLoadedState(
        updated,
        hasMore: currentState.hasMore,
        nextPageUrl: currentState.nextPageUrl,
      ));

      // Send to backend
      try {
        await notificationRepository.markAsRead([event.notificationId]);
      } catch (e) {
        // On error, revert optimistic update
        emit(currentState);
        emit(NotificationError('Failed to mark as read: ${e.toString()}'));
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
        // Optimistic: mark all as read locally
        final updated = currentState.notifications
            .map((notification) => notification.isRead ? notification : _withReadState(notification))
            .toList();

        emit(_buildLoadedState(
          updated,
          hasMore: currentState.hasMore,
          nextPageUrl: currentState.nextPageUrl,
        ));

        try {
          await notificationRepository.markAsRead(unreadIds);
        } catch (e) {
          // Revert on error
          emit(currentState);
          emit(NotificationError('Failed to mark all as read: ${e.toString()}'));
        }
      }
    }
  }

  void _onNewPush(NewPushNotificationEvent event, Emitter<NotificationState> emit) {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final updatedList = [event.notification, ...currentState.notifications];
      emit(_buildLoadedState(
        updatedList,
        hasMore: currentState.hasMore,
        nextPageUrl: currentState.nextPageUrl,
      ));
    }
  }
}