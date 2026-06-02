import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../dtos/dispute_dto.dart';
import '../models/dispute.dart';

final getIt = GetIt.instance;

class DisputeRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  /// Fetch all disputes for current buyer
  Future<List<Dispute>> fetchMyDisputes() async {
    try {
      final response = await _apiClient.dio.get('/api/disputes/');
      final List<dynamic> data = _extractList(response.data);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => Dispute.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch specific dispute details
  Future<DisputeResponse> fetchDisputeDetail(String uuid) async {
    try {
      final response = await _apiClient.dio.get('/api/disputes/$uuid/');
      return DisputeResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new dispute for an order
  Future<DisputeResponse> createDispute(CreateDisputeRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/disputes/create/',
        data: request.toJson(),
      );
      return DisputeResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Resolve a dispute (admin/support only, but buyer can view)
  Future<DisputeResponse> resolveDispute(ResolveDisputeRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/disputes/${request.uuid}/resolve/',
        data: request.toJson(),
      );
      return DisputeResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ PRIVATE HELPER METHODS ============

  dynamic _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] ?? [];
    }
    if (data is Map && data.containsKey('data')) {
      return data['data'] ?? [];
    }
    return [];
  }

  Exception _handleError(dynamic error) {
    if (error is Exception) return error;
    return Exception(error.toString());
  }
}
