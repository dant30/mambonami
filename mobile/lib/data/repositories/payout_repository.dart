import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/payout_summary.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class PayoutRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<PayoutSummary> getTransportPayoutSummary() async {
    try {
      final response = await _apiClient.dio.get(kTransportPayoutSummaryEndpoint);
      return PayoutSummary.fromJson(normalizeMap(response.data));
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
