// mobile/lib/data/repositories/trip_repository.dart
import 'package:dio/dio.dart';
import 'dart:io';
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
      final endpoint = '/api/logistics/my-trips/$uuid/pickup/';
      if (data.photoPath != null) {
        final form = FormData();
        final payload = data.toJson();
        // Add non-file fields
        payload.forEach((k, v) {
          if (k != 'pickup_photo' && v != null)
            form.fields.add(MapEntry(k, v.toString()));
        });
        // Attach file
        final file = File(data.photoPath!);
        form.files.add(MapEntry(
          'pickup_photo',
          MultipartFile.fromFileSync(file.path,
              filename: file.path.split(Platform.pathSeparator).last),
        ));

        await _apiClient.dio.post(endpoint, data: form);
      } else {
        await _apiClient.dio.post(endpoint, data: data.toJson());
      }

      return await getTripDetail(uuid);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> markDelivery(String uuid, TripDeliveryDto data) async {
    try {
      if (data.photoPath != null) {
        final form = FormData();
        final payload = data.toJson();
        payload.forEach((k, v) {
          if (k != 'delivery_photo' && v != null)
            form.fields.add(MapEntry(k, v.toString()));
        });
        final file = File(data.photoPath!);
        form.files.add(MapEntry(
          'delivery_photo',
          MultipartFile.fromFileSync(file.path,
              filename: file.path.split(Platform.pathSeparator).last),
        ));

        final response = await _apiClient.dio
            .patch('/api/logistics/my-trips/$uuid/', data: form);
        return Trip.fromJson(response.data);
      }

      final response = await _apiClient.dio
          .patch('/api/logistics/my-trips/$uuid/', data: data.toJson());
      return Trip.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TripArriveResponse> arriveAtFarm(String tripUuid) async {
    try {
      final response = await _apiClient.dio
          .post('/api/logistics/my-trips/$tripUuid/arrive/');
      return TripArriveResponse.fromJson(response.data as Map<String, dynamic>);
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
