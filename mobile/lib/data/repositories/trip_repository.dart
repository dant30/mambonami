import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/trip.dart';
import '../dtos/trip_dto.dart';

final getIt = GetIt.instance;

class TripRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<Trip>> getAvailableOrders() async {
    try {
      final response =
          await _apiClient.dio.get('/api/logistics/orders/available/');
      final List<dynamic> data = _extractList(response.data);
      return data
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> assignToMe(int orderId) async {
    try {
      final response =
          await _apiClient.dio.post('/api/logistics/orders/$orderId/assign/');
      return Trip.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Trip>> getMyTrips() async {
    try {
      final response = await _apiClient.dio.get('/api/logistics/my-trips/');
      final List<dynamic> data = _extractList(response.data);
      return data
          .map((json) => Trip.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> getTripDetail(String uuid) async {
    try {
      final response =
          await _apiClient.dio.get('/api/logistics/my-trips/$uuid/');
      return Trip.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> markPickup(String uuid, TripPickupDto data) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/logistics/my-trips/$uuid/',
        data: data.toJson(),
      );
      return Trip.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GenerateOtpResponse> generateOtp(String tripUuid) async {
    try {
      final response = await _apiClient.dio
          .post('/api/logistics/my-trips/$tripUuid/generate-otp/');
      return GenerateOtpResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyOtp(String tripUuid, String otp) async {
    try {
      await _apiClient.dio.post('/api/logistics/trips/$tripUuid/verify-otp/',
          data: {'otp': otp});
    } catch (e) {
      throw _handleError(e);
    }
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    if (responseData is Map<String, dynamic>) {
      final candidates = ['results', 'data', 'orders', 'items'];
      for (final key in candidates) {
        final value = responseData[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return [];
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null && data['error'] != null) return data['error'];
      if (data != null && data['detail'] != null) return data['detail'];
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}
