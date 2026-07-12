// mobile/lib/data/repositories/trip_repository.dart
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/trip.dart';
import '../dtos/trip_dto.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class TripRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<Trip>> getAvailableOrders() async {
    try {
      final response =
          await _apiClient.dio.get('/api/logistics/orders/available/');
        return normalizeList<Map<String, dynamic>>(response.data).map(Trip.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> assignToMe(int orderId) async {
    try {
      final response =
          await _apiClient.dio.post('/api/logistics/orders/$orderId/assign/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Trip>> getMyTrips() async {
    try {
      final response = await _apiClient.dio.get('/api/logistics/my-trips/');
      final payload = response.data is Map<String, dynamic> && (response.data as Map<String, dynamic>).containsKey('results')
          ? response.data['results']
          : response.data;
      return normalizeList<Map<String, dynamic>>(payload).map(Trip.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> getTripDetail(String uuid) async {
    try {
      final response =
          await _apiClient.dio.get('/api/logistics/my-trips/$uuid/');
      return Trip.fromJson(normalizeMap(response.data));
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
          if (k != 'pickup_photo' && v != null) {
            form.fields.add(MapEntry(k, v.toString()));
          }
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
          if (k != 'delivery_photo' && v != null) {
            form.fields.add(MapEntry(k, v.toString()));
          }
        });
        final file = File(data.photoPath!);
        form.files.add(MapEntry(
          'delivery_photo',
          MultipartFile.fromFileSync(file.path,
              filename: file.path.split(Platform.pathSeparator).last),
        ));

        final response = await _apiClient.dio
            .patch('/api/logistics/my-trips/$uuid/', data: form);
        return Trip.fromJson(normalizeMap(response.data));
      }

      final response = await _apiClient.dio
          .patch('/api/logistics/my-trips/$uuid/', data: data.toJson());
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TripArriveResponse> arriveAtFarm(String tripUuid) async {
    try {
      final response = await _apiClient.dio
          .post('/api/logistics/my-trips/$tripUuid/arrive/');
      return TripArriveResponse.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GenerateOtpResponse> generateOtp(String tripUuid) async {
    try {
      final response = await _apiClient.dio
          .post('/api/logistics/my-trips/$tripUuid/generate-otp/');
      return GenerateOtpResponse.fromJson(normalizeMap(response.data));
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

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = normalizeMap(error.response?.data);
      if (data['error'] != null) return stringValue(data['error']);
      if (data['detail'] != null) return stringValue(data['detail']);
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}
