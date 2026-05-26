import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/notification.dart';

final getIt = GetIt.instance;

class NotificationRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/api/notifications/');
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic>) {
          // DRF pagination returns { count, next, previous, results: [...] }
          if (raw.containsKey('results') && raw['results'] is List) {
            items = raw['results'] as List<dynamic>;
          } else if (raw.containsKey('data') && raw['data'] is List) {
            items = raw['data'] as List<dynamic>;
          } else {
            // Fallback: try to find first List value
            final firstList = raw.values.firstWhere((v) => v is List, orElse: () => null);
            if (firstList is List) items = firstList;
          }
        }

        return items.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch notifications');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAsRead(List<int> notificationIds) async {
    try {
      await _apiClient.dio.post('/api/notifications/mark-read/', data: {
        'notification_ids': notificationIds,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      return error.response?.data['detail'] ?? error.message;
    }
    return error.toString();
  }
}