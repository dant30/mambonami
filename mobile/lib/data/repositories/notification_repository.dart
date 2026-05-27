import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../dtos/notifications_dto.dart';

final getIt = GetIt.instance;

class NotificationRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<NotificationsResponseDTO> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/api/notifications/');
      if (response.statusCode == 200) {
        return NotificationsResponseDTO.fromJson(response.data);
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