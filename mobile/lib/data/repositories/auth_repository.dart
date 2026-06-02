// mobile/lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/secure_storage.dart';
import '../local/cache_manager.dart';
import '../local/database_helper.dart';

final getIt = GetIt.instance;

class AuthRepository {
  final ApiClient _apiClient = getIt<ApiClient>();
  final SecureStorage _secureStorage = getIt<SecureStorage>();
  final CacheManager _cacheManager = CacheManager.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> getCachedProfile() async {
    return await _cacheManager.getJson(kCachedProfileKey);
  }

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
        final user = response.data['user'] as Map<String, dynamic>;
        await _secureStorage.saveTokens(tokens['access'], tokens['refresh']);
        await _secureStorage.saveUserRole(role);
        await _secureStorage.saveUserPhone(phone);
        await _cacheManager.saveJson(kCachedProfileKey, user);
        await _databaseHelper.insertOrUpdateRecord(kUserTable, phone, user);
        return user;
      }
      throw Exception('Registration failed');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _apiClient.dio.post(
        kLoginEndpoint,
        data: {'phone': phone, 'password': password},
      );

      if (response.statusCode != 200) {
        throw Exception('Login failed with status ${response.statusCode}');
      }

      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format from server');
      }

      final responseData = response.data as Map<String, dynamic>;

      // Extract tokens
      if (responseData['tokens'] == null || responseData['tokens'] is! Map) {
        throw Exception('Missing or invalid tokens in response');
      }
      final tokens = responseData['tokens'] as Map<String, dynamic>;

      if (tokens['access'] == null || tokens['refresh'] == null) {
        throw Exception('Missing access or refresh token');
      }

      // Extract user data
      if (responseData['user'] == null || responseData['user'] is! Map) {
        throw Exception('Missing or invalid user data in response');
      }
      final user = responseData['user'] as Map<String, dynamic>;

      // Validate required user fields
      if (user['role'] == null || user['phone'] == null) {
        throw Exception('Missing required user fields (role or phone)');
      }

      // Save tokens and user info to secure storage
      await _secureStorage.saveTokens(tokens['access'] as String, tokens['refresh'] as String);
      await _secureStorage.saveUserRole(user['role'] as String);
      await _secureStorage.saveUserPhone(user['phone'] as String);
      await _cacheManager.saveJson(kCachedProfileKey, user);
      await _databaseHelper.insertOrUpdateRecord(kUserTable, user['phone'] as String, user);

      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(kProfileEndpoint);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final profile = response.data as Map<String, dynamic>;
        await _cacheManager.saveJson(kCachedProfileKey, profile);
        final userId = profile['phone'] as String?;
        if (userId != null) {
          await _databaseHelper.insertOrUpdateRecord(kUserTable, userId, profile);
        }
        return profile;
      }

      final cached = await getCachedProfile();
      if (cached != null) {
        return cached;
      }

      throw Exception('Failed to load profile');
    } catch (e) {
      final cached = await getCachedProfile();
      if (cached != null) {
        return cached;
      }
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
    await _cacheManager.remove(kCachedProfileKey);
    await _databaseHelper.clearTable(kUserTable);
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Log error details for debugging
      print('AuthRepository Error - Status: $statusCode, Type: ${error.type}');
      if (data != null) {
        print('Error Response: $data');
      }

      // Handle specific HTTP status codes
      switch (statusCode) {
        case 400:
          return data?['detail'] ?? 'Invalid phone or password format';
        case 401:
          return data?['detail'] ?? 'Invalid phone number or password';
        case 409:
          return data?['detail'] ?? 'User already exists';
        case 429:
          return 'Too many login attempts. Please try again later.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          if (data != null) {
            if (data is Map && data['detail'] != null) {
              return data['detail'];
            }
            if (data is Map && data['error'] != null) {
              return data['error'];
            }
          }
          return 'Network error: ${error.message}';
      }
    }
    
    // Handle validation errors from response parsing
    if (error is Exception) {
      print('AuthRepository Exception: ${error.toString()}');
    }
    
    return error.toString();
  }
}