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

  Future<void> _onFetch(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final dto = await notificationRepository.getNotifications();
      final unreadCount = dto.notifications.where((n) => !n.isRead).length;
      emit(NotificationLoaded(
        dto.notifications,
        unreadCount,
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
      final updated = currentState.notifications.map((n) {
        return n.id == event.notificationId
            ? NotificationModel(
                id: n.id,
                uuid: n.uuid,
                channel: n.channel,
                title: n.title,
                body: n.body,
                metadata: n.metadata,
                status: 'read',
                createdAt: n.createdAt,
                readAt: DateTime.now(),
              )
            : n;
      }).toList();

      final newUnreadCount = updated.where((n) => !n.isRead).length;
      emit(NotificationLoaded(
        updated,
        newUnreadCount,
        hasMore: currentState.hasMore,
        nextPageUrl: currentState.nextPageUrl,
      ));

      // Send to backend
      try {
        await notificationRepository.markAsRead([event.notificationId]);
      } catch (e) {
        // On error, revert optimistic update
        emit(NotificationLoaded(
          currentState.notifications,
          currentState.unreadCount,
          hasMore: currentState.hasMore,
          nextPageUrl: currentState.nextPageUrl,
        ));
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
            .map((n) => n.isRead
                ? n
                : NotificationModel(
                    id: n.id,
                    uuid: n.uuid,
                    channel: n.channel,
                    title: n.title,
                    body: n.body,
                    metadata: n.metadata,
                    status: 'read',
                    createdAt: n.createdAt,
                    readAt: DateTime.now(),
                  ))
            .toList();

        emit(NotificationLoaded(
          updated,
          0,
          hasMore: currentState.hasMore,
          nextPageUrl: currentState.nextPageUrl,
        ));

        try {
          await notificationRepository.markAsRead(unreadIds);
        } catch (e) {
          // Revert on error
          emit(NotificationLoaded(
            currentState.notifications,
            currentState.unreadCount,
            hasMore: currentState.hasMore,
            nextPageUrl: currentState.nextPageUrl,
          ));
          emit(NotificationError('Failed to mark all as read: ${e.toString()}'));
        }
      }
    }
  }

  void _onNewPush(NewPushNotificationEvent event, Emitter<NotificationState> emit) {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final updatedList = [event.notification, ...currentState.notifications];
      final unreadCount = updatedList.where((n) => !n.isRead).length;
      emit(NotificationLoaded(
        updatedList,
        unreadCount,
        hasMore: currentState.hasMore,
        nextPageUrl: currentState.nextPageUrl,
      ));
    }
  }
}