import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/paybill_transaction.dart';
import '../models/paybill_settlement.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class PaybillRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<PaybillTransaction>> getTransactions({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get(kPaybillTransactionsEndpoint, queryParameters: query);
      return normalizeList<Map<String, dynamic>>(response.data).map((m) => PaybillTransaction.fromJson(normalizeMap(m))).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PaybillSettlement>> getSettlements({Map<String, dynamic>? query}) async {
    try {
      final response = await _apiClient.dio.get(kPaybillSettlementsEndpoint, queryParameters: query);
      return normalizeList<Map<String, dynamic>>(response.data).map((m) => PaybillSettlement.fromJson(normalizeMap(m))).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<double> getFloatBalance() async {
    try {
      final response = await _apiClient.dio.get(kPaybillFloatBalanceEndpoint);
      final data = normalizeMap(response.data);
      final val = data['float_balance'] ?? data['balance'] ?? data['amount'];
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '0') ?? 0.0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Developer helper: trigger simulation (admin/dev only)
  Future<Map<String, dynamic>> simulate(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post(kPaybillSimulateEndpoint, data: payload);
      return normalizeMap(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = normalizeMap(error.response?.data);
      if (data['detail'] != null) return stringValue(data['detail']);
      if (data['error'] != null) return stringValue(data['error']);
      return error.message ?? 'PayBill request failed';
    }
    return error.toString();
  }
}
