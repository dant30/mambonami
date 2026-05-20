import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/order.dart';

class CreateOrderRequest {
  final List<CartItemDto> items;
  final String deliveryAddress;
  final String scheduledDate;
  final String scheduledTimeWindow;

  CreateOrderRequest({
    required this.items,
    required this.deliveryAddress,
    required this.scheduledDate,
    required this.scheduledTimeWindow,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'delivery_address': deliveryAddress,
    'scheduled_date': scheduledDate,
    'scheduled_time_window': scheduledTimeWindow,
  };
}

class CartItemDto {
  final int productId;
  final double quantity;

  CartItemDto({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

class OrderRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<Map<String, dynamic>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiClient.dio.post('/api/orders/', data: request.toJson());
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> fetchMyOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
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
  Future<List<Order>> fetchFarmerSubOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/farmer/suborders/');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> confirmSubOrder(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborders/$subOrderId/confirm/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markSubOrderReady(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborders/$subOrderId/ready/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Transport provider endpoints
  Future<List<Order>> fetchAvailableOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/logistics/orders/available/');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
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

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null && data['detail'] != null) return data['detail'];
      if (data != null && data['error'] != null) return data['error'];
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}