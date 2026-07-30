import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../models/verification_document.dart';
import '../dtos/verification_dto.dart';
import 'response_utils.dart';

final getIt = GetIt.instance;

class VerificationRepository {
  final ApiClient _apiClient = getIt<ApiClient>();

  Future<List<VerificationDocument>> listDocuments() async {
    try {
      final response = await _apiClient.dio.get(kVerificationDocumentsEndpoint);
      return normalizeList<Map<String, dynamic>>(response.data).map((m) => VerificationDocument.fromJson(normalizeMap(m))).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<VerificationDocument> getDocument(String uuid) async {
    try {
      final response = await _apiClient.dio.get('$kVerificationDocumentDetailEndpoint$uuid/');
      return VerificationDocument.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<VerificationDocument> uploadDocument(VerificationDocumentCreateRequest req) async {
    try {
      final form = await req.toFormData();
      final response = await _apiClient.dio.post(kVerificationDocumentsEndpoint, data: form);
      return VerificationDocument.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<VerificationDocument> reviewDocument(String uuid, Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post('$kVerificationDocumentDetailEndpoint$uuid/review/', data: payload);
      return VerificationDocument.fromJson(normalizeMap(response.data));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTrustScore([String? uuid]) async {
    try {
      final path = uuid == null ? kTrustScoreEndpoint : '$kTrustScoreEndpoint$uuid/';
      final response = await _apiClient.dio.get(path);
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
      return error.message ?? 'Verification request failed';
    }
    return error.toString();
  }
}
