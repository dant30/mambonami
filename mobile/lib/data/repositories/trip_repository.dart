// mobile/lib/data/repositories/trip_repository.dart
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/trip.dart';
import '../dtos/trip_dto.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class TripRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<Trip>> getAvailableOrders() async {
    try {
      final response = await _apiClient.dio.get(kAvailableOrdersEndpoint);
      return normalizeList<Map<String, dynamic>>(response.data).map(Trip.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> assignToMe(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripAssignEndpoint$tripUuid/assign/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Trip>> getMyTrips() async {
    try {
      final response = await _apiClient.dio.get(kMyTripsEndpoint);
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
      final response = await _apiClient.dio.get('$kMyTripsEndpoint$uuid/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> markPickup(String uuid, TripPickupDto data) async {
    try {
      final endpoint = '$kMyTripsEndpoint$uuid/pickup/';
      if (data.photoPath != null) {
        final form = FormData();
        final payload = data.toJson();
        payload.forEach((k, v) {
          if (k != 'pickup_photo' && v != null) {
            form.fields.add(MapEntry(k, v.toString()));
          }
        });
        final file = File(data.photoPath!);
        form.files.add(MapEntry(
          'pickup_photo',
          MultipartFile.fromFileSync(file.path,
              filename: file.path.split(Platform.pathSeparator).last),
        ));
        final response = await _apiClient.dio.post(endpoint, data: form);
        return Trip.fromJson(normalizeMap(response.data));
      }
      final response = await _apiClient.dio.post(endpoint, data: data.toJson());
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> markDelivery(String uuid, TripDeliveryDto data) async {
    try {
      final endpoint = '$kMyTripsEndpoint$uuid/arrive-delivery/';
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
        final response = await _apiClient.dio.post(endpoint, data: form);
        return Trip.fromJson(normalizeMap(response.data));
      }
      final response = await _apiClient.dio.post(endpoint, data: data.toJson());
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> startPickupNavigation(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripStartPickupNavEndpoint$tripUuid/start-pickup-nav/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> arriveAtPickup(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripArrivePickupEndpoint$tripUuid/arrive-pickup/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> startDeliveryNavigation(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripStartDeliveryNavEndpoint$tripUuid/start-delivery-nav/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Trip> arriveAtDelivery(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripArriveDeliveryEndpoint$tripUuid/arrive-delivery/');
      return Trip.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TripArriveResponse> arriveAtFarm(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripArrivePickupEndpoint$tripUuid/arrive-pickup/');
      return TripArriveResponse.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<GenerateOtpResponse> generateOtp(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('$kTripGenerateOtpEndpoint$tripUuid/generate-otp/');
      return GenerateOtpResponse.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyOtp(String tripUuid, String otp) async {
    try {
      await _apiClient.dio.post('$kTripVerifyOtpEndpoint$tripUuid/verify-otp/', data: {'otp': otp});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> pingLocation(String tripUuid, TripLocationPingDto data) async {
    try {
      await _apiClient.dio.post('$kTripLocationEndpoint$tripUuid/location/', data: data.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadMedia(String tripUuid, String mediaType, String filePath, {String? caption}) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('media_type', mediaType));
      if (caption != null && caption.isNotEmpty) form.fields.add(MapEntry('caption', caption));
      final file = File(filePath);
      form.files.add(MapEntry('image', MultipartFile.fromFileSync(file.path, filename: file.path.split(Platform.pathSeparator).last)));
      await _apiClient.dio.post('$kTripMediaEndpoint$tripUuid/media/', data: form);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = normalizeMap(error.response?.data);
      if (data['error'] != null) return stringValue(data['error']);
      if (data['detail'] != null) return stringValue(data['detail']);
      if (error.response?.data is String) return error.response!.data as String;
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}
