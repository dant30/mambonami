
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/secure_storage.dart';

class AuthRepository {
  final ApiClient _apiClient = getIt<ApiClient>();
  final SecureStorage _secureStorage = getIt<SecureStorage>();

  Future<void> registerInit(String phone, String role) async {
    try {
      final response = await _apiClient.dio.post(kRegisterInitEndpoint, data: {
        'phone': phone,
        'role': role,
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerVerify({
    required String phone,
    required String otp,
    required String username,
    required String password,
    required String role,
    String? farmGps,
    String? mpesaNumber,
    String? vehicleType,
    String? licensePlate,
  }) async {
    try {
      final data = {
        'phone': phone,
        'otp': otp,
        'username': username,
        'password': password,
        'confirm_password': password,
        'role': role,
      };
      if (farmGps != null) data['farm_gps'] = farmGps;
      if (mpesaNumber != null) data['mpesa_number'] = mpesaNumber;
      if (vehicleType != null) data['vehicle_type'] = vehicleType;
      if (licensePlate != null) data['license_plate'] = licensePlate;

      final response = await _apiClient.dio.post(kRegisterVerifyEndpoint, data: data);
      if (response.statusCode == 201) {
        final tokens = response.data['tokens'];
        await _secureStorage.saveTokens(tokens['access'], tokens['refresh']);
        await _secureStorage.saveUserRole(role);
        await _secureStorage.saveUserPhone(phone);
        return response.data['user'];
      }
      throw Exception('Registration failed');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _apiClient.dio.post(kLoginEndpoint, data: {
        'phone': phone,
        'password': password,
      });
      if (response.statusCode == 200) {
        final tokens = response.data;
        await _secureStorage.saveTokens(tokens['access'], tokens['refresh']);
        // After login, fetch user profile to get role
        final user = await getProfile();
        await _secureStorage.saveUserRole(user['role']);
        await _secureStorage.saveUserPhone(phone);
        return user;
      }
      throw Exception('Login failed');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(kProfileEndpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPasswordInit(String phone) async {
    try {
      final response = await _apiClient.dio.post(kForgotPasswordInitEndpoint, data: {
        'phone': phone,
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to send reset OTP');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPasswordVerify(String phone, String otp, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(kForgotPasswordVerifyEndpoint, data: {
        'phone': phone,
        'otp': otp,
        'new_password': newPassword,
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null && data['detail'] != null) {
        return data['detail'];
      }
      if (data != null && data['error'] != null) {
        return data['error'];
      }
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}