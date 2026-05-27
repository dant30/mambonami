// mobile/lib/data/dtos/notifications_dto.dart
import '../models/notification.dart';

class NotificationsResponseDTO {
  final List<NotificationModel> notifications;
  final int? count;
  final String? next;
  final String? previous;

  NotificationsResponseDTO({
    required this.notifications,
    this.count,
    this.next,
    this.previous,
  });

  factory NotificationsResponseDTO.fromJson(dynamic json) {
    if (json is List) {
      // Direct list response
      return NotificationsResponseDTO(
        notifications: List<NotificationModel>.from(
          json.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)),
        ),
      );
    } else if (json is Map<String, dynamic>) {
      // Paginated response (DRF pagination)
      final items = json['results'] ?? json['data'] ?? [];
      return NotificationsResponseDTO(
        notifications: List<NotificationModel>.from(
          (items as List).map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)),
        ),
        count: json['count'] as int?,
        next: json['next'] as String?,
        previous: json['previous'] as String?,
      );
    }
    return NotificationsResponseDTO(notifications: []);
  }

  bool get hasPagination => count != null;
  bool get hasMore => next != null;
  bool get hasPrevious => previous != null;
}
