import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../dtos/dispute_dto.dart';
import '../models/dispute.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class DisputeRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  /// Fetch all disputes for current buyer
  Future<List<Dispute>> fetchMyDisputes() async {
    try {
      final response = await _apiClient.dio.get('/api/disputes/');
        return normalizeList<Map<String, dynamic>>(response.data).map(Dispute.fromJson).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch specific dispute details
  Future<DisputeResponse> fetchDisputeDetail(String uuid) async {
    try {
      final response = await _apiClient.dio.get('/api/disputes/$uuid/');
      return DisputeResponse.fromJson(normalizeMap(response.data));
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
      return DisputeResponse.fromJson(normalizeMap(response.data));
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
      return DisputeResponse.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ PRIVATE HELPER METHODS ============

  Exception _handleError(dynamic error) {
    if (error is Exception) return error;
    return Exception(error.toString());
  }
}
