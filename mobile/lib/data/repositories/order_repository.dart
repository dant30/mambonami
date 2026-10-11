import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../models/order.dart';
import '../dtos/order_dto.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class OrderRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<Map<String, dynamic>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiClient.dio.post('/api/orders/create/', data: request.toJson());
      return normalizeMap(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> fetchMyOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/');
      final payload = response.data is Map<String, dynamic> && (response.data as Map<String, dynamic>).containsKey('results')
          ? response.data['results']
          : response.data;
      return normalizeList<Map<String, dynamic>>(payload).map(Order.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> fetchOrderDetail(String uuid) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/$uuid/');
      return Order.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order?> fetchActiveOrder() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/active/');
      if (response.statusCode == 200 && response.data != null) {
        return Order.fromJson(normalizeMap(response.data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Farmer endpoints
  Future<List<SubOrder>> fetchFarmerSubOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/orders/suborders/');
      final payload = response.data is Map<String, dynamic> && (response.data as Map<String, dynamic>).containsKey('results')
          ? response.data['results']
          : response.data;
      return normalizeList<Map<String, dynamic>>(payload).map(SubOrder.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> confirmSubOrder(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborders/$subOrderId/confirm/', data: {'action': 'confirm'});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectSubOrder(int subOrderId) async {
    try {
      await _apiClient.dio.post('/api/orders/suborders/$subOrderId/confirm/', data: {'action': 'reject'});
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

  Future<SubOrder> fetchFarmerSubOrder(int subOrderId) async {
    try {
      final response = await _apiClient.dio.get('/api/orders/suborders/$subOrderId/');
      return SubOrder.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Transport provider endpoints
  Future<List<Order>> fetchAvailableOrders() async {
    try {
      final response = await _apiClient.dio.get('/api/logistics/orders/available/');
      return normalizeList<Map<String, dynamic>>(response.data).map(Order.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assignToOrder(String tripUuid) async {
    try {
      await _apiClient.dio.post('/api/logistics/trips/$tripUuid/assign/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = normalizeMap(error.response?.data);
      if (data['detail'] != null) return stringValue(data['detail']);
      if (data['error'] != null) return stringValue(data['error']);
      if (error.response?.data is String) return error.response!.data as String;
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}