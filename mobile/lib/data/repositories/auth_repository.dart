// mobile/lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/secure_storage.dart';
import '../local/cache_manager.dart';
import '../local/database_helper.dart';
import 'response_utils.dart';

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
      final normalizedPhone = _normalizePhoneNumber(phone);
      final response = await _apiClient.dio.post(kRegisterInitEndpoint, data: {
        'phone': normalizedPhone,
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
    String? email,
    String? farmGps,
    String? mpesaNumber,
    String? vehicleType,
    String? licensePlate,
  }) async {
    try {
      final normalizedPhone = _normalizePhoneNumber(phone);
      final data = {
        'phone': normalizedPhone,
        'otp': otp,
        'username': username,
        'password': password,
        'confirm_password': password,
        'role': role,
      };
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (farmGps != null) data['farm_gps'] = farmGps;
      if (mpesaNumber != null) data['mpesa_number'] = mpesaNumber;
      if (vehicleType != null) data['vehicle_type'] = vehicleType;
      if (licensePlate != null) data['license_plate'] = licensePlate;

      final response = await _apiClient.dio.post(kRegisterVerifyEndpoint, data: data);
      if (response.statusCode == 201) {
        final responseData = normalizeMap(response.data);
        final tokens = normalizeMap(responseData['tokens']);
        final user = normalizeMap(responseData['user']);
        final accessToken = stringValue(tokens['access']);
        final refreshToken = stringValue(tokens['refresh']);
        if (accessToken.isEmpty || refreshToken.isEmpty) {
          throw Exception('Missing tokens in registration response');
        }
        await _secureStorage.saveTokens(accessToken, refreshToken);
        await _secureStorage.saveUserRole(stringValue(user['role'], fallback: role));
        await _secureStorage.saveUserPhone(stringValue(user['phone'], fallback: normalizedPhone));
        await _cacheManager.saveJson(kCachedProfileKey, user);
        await _databaseHelper.insertOrUpdateRecord(kUserTable, stringValue(user['phone'], fallback: normalizedPhone), user);
        return user;
      }
      throw Exception('Registration failed');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final normalizedPhone = _normalizePhoneNumber(phone);
      final response = await _apiClient.dio.post(
        kLoginEndpoint,
        data: {'phone': normalizedPhone, 'password': password},
      );

      if (response.statusCode != 200) {
        throw Exception('Login failed with status ${response.statusCode}');
      }

      // Validate response structure
      final responseData = normalizeMap(response.data);
      if (responseData.isEmpty) {
        throw Exception('Invalid response format from server');
      }

      // Extract tokens
      if (responseData['tokens'] == null) {
        throw Exception('Missing or invalid tokens in response');
      }
      final tokens = normalizeMap(responseData['tokens']);
      final accessToken = stringValue(tokens['access']);
      final refreshToken = stringValue(tokens['refresh']);

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw Exception('Missing access or refresh token');
      }

      // Extract user data
      if (responseData['user'] == null) {
        throw Exception('Missing or invalid user data in response');
      }
      final user = normalizeMap(responseData['user']);

      // Validate required user fields
      final userRole = stringValue(user['role']);
      final userPhone = stringValue(user['phone']);
      if (userRole.isEmpty || userPhone.isEmpty) {
        throw Exception('Missing required user fields (role or phone)');
      }
      final formattedPhone = _normalizePhoneNumber(userPhone);
      user['phone'] = formattedPhone;

      // Save tokens and user info to secure storage
      await _secureStorage.saveTokens(accessToken, refreshToken);
      await _secureStorage.saveUserRole(userRole);
      await _secureStorage.saveUserPhone(formattedPhone);
      await _cacheManager.saveJson(kCachedProfileKey, user);
      await _databaseHelper.insertOrUpdateRecord(kUserTable, formattedPhone, user);

      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(kProfileEndpoint);
      if (response.statusCode == 200) {
        final profile = normalizeMap(response.data);
        if (profile.isNotEmpty) {
        final phone = stringValue(profile['phone']);
        if (phone.isNotEmpty) {
          final formattedPhone = _normalizePhoneNumber(phone);
          profile['phone'] = formattedPhone;
        }
        await _cacheManager.saveJson(kCachedProfileKey, profile);
        final userId = stringValue(profile['phone']);
        if (userId.isNotEmpty) {
          await _databaseHelper.insertOrUpdateRecord(kUserTable, userId, profile);
        }
        return profile;
        }
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
      final normalizedPhone = _normalizePhoneNumber(phone);
      final response = await _apiClient.dio.post(kForgotPasswordInitEndpoint, data: {
        'phone': normalizedPhone,
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
      final normalizedPhone = _normalizePhoneNumber(phone);
      final response = await _apiClient.dio.post(kForgotPasswordVerifyEndpoint, data: {
        'phone': normalizedPhone,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': newPassword,
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        kPasswordChangeEndpoint,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _apiClient.dio.delete(kProfileEndpoint);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete account');
      }
      await logout();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    await _cacheManager.remove(kCachedProfileKey);
    await _databaseHelper.clearTable(kUserTable);
  }

  String _normalizePhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.startsWith('+')) {
      final stripped = cleaned.substring(1);
      if (RegExp(r'^(?:254|0)?(7\d{8})$').hasMatch(stripped)) {
        final match = RegExp(r'^(?:254|0)?(7\d{8})$').firstMatch(stripped);
        return '+254${match?.group(1)}';
      }
    }
    if (RegExp(r'^(?:254|0)?(7\d{8})$').hasMatch(cleaned)) {
      final match = RegExp(r'^(?:254|0)?(7\d{8})$').firstMatch(cleaned);
      return '+254${match?.group(1)}';
    }
    return phone.trim();
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = normalizeMap(error.response?.data);
      final serverMessage = _extractServerMessage(data);

      // Log error details for debugging
      print('AuthRepository Error - Status: $statusCode, Type: ${error.type}');
      if (data.isNotEmpty) {
        print('Error Response: $data');
      }

      // Handle specific HTTP status codes
      switch (statusCode) {
        case 400:
          return serverMessage.isNotEmpty
              ? serverMessage
              : 'Invalid phone or password format';
        case 401:
          return serverMessage.isNotEmpty
              ? serverMessage
              : 'Invalid phone number or password';
        case 409:
          return serverMessage.isNotEmpty ? serverMessage : 'User already exists';
        case 429:
          return 'Too many login attempts. Please try again later.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          if (data.isNotEmpty) {
            if (serverMessage.isNotEmpty) return serverMessage;
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

  String _extractServerMessage(Map<String, dynamic> data) {
    for (final key in const ['detail', 'error', 'message']) {
      final message = stringValue(data[key]);
      if (message.isNotEmpty) return message;
    }

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        return '${entry.key}: ${value.map((item) => item.toString()).join(', ')}';
      }
      if (value is Map && value.isNotEmpty) {
        final nested = _extractServerMessage(normalizeMap(value));
        if (nested.isNotEmpty) return '${entry.key}: $nested';
      }
      final message = stringValue(value);
      if (message.isNotEmpty) return '${entry.key}: $message';
    }

    return '';
  }
}
