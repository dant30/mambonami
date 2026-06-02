import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/order.dart';
import '../dtos/order_dto.dart';

final getIt = GetIt.instance;

class OrderRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<Map<String, dynamic>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiClient.dio.post('/api/orders/cart/create-order/', data: request.toJson());
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> fetchMyOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/');
      final List<dynamic> data = _extractList(response.data);
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> fetchOrderDetail(String uuid) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/$uuid/');
      return Order.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Farmer endpoints
  Future<List<SubOrder>> fetchFarmerSubOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/farmer/suborders/');
      final List<dynamic> data = _extractList(response.data);
      return data.map((json) => SubOrder.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> confirmSubOrder(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborder/$subOrderId/confirm/', data: {'action': 'confirm'});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markSubOrderReady(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborder/$subOrderId/ready/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SubOrder> fetchFarmerSubOrder(int subOrderId) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/farmer/suborders/$subOrderId/');
      return SubOrder.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Transport provider endpoints
  Future<List<Order>> fetchAvailableOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/logistics/orders/available/');
      final List<dynamic> data = _extractList(response.data);
      return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assignToOrder(int orderId) async {
    try {
      await _apiClient.dio.post('/api/logistics/orders/$orderId/assign/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delivery OTP
  Future<String> generateOTP(String tripUuid) async {
    try {
      final response = await _apiClient.dio.post('/api/logistics/my-trips/$tripUuid/generate-otp/');
      return response.data['otp'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyOTP(String tripUuid, String otp) async {
    try {
      await _apiClient.dio.post('/api/logistics/trips/$tripUuid/verify-otp/', data: {'otp': otp});
    } catch (e) {
      throw _handleError(e);
    }
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    if (responseData is Map<String, dynamic>) {
      final candidates = ['results', 'data', 'orders', 'items', 'products'];
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
      if (data != null) {
        if (data is Map<String, dynamic>) {
          if (data['detail'] != null) return data['detail'];
          if (data['error'] != null) return data['error'];
        }
        if (data is String) return data;
      }
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}