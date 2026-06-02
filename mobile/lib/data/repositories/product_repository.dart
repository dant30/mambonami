
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../local/database_helper.dart';
import '../models/product.dart';

final getIt = GetIt.instance;

class ProductRepository {
  final ApiClient _apiClient = getIt<ApiClient>();
  final DatabaseHelper _databaseHelper = getIt<DatabaseHelper>();

  /// Attempt to load products from local DB cache
  Future<List<Product>> getCachedProducts({String? categoryCode, int? farmerId}) async {
    final records = await _databaseHelper.getRecords(kProductTable);
    return records.map((r) => Product.fromJson(r)).toList();
  }

  Future<List<Product>> getProducts({String? categoryCode, int? farmerId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryCode != null) queryParams['category_code'] = categoryCode;
      if (farmerId != null) queryParams['farmer_id'] = farmerId;

      final response = await _apiClient.dio.get('/api/products/', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractList(response.data);
        final products = data.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();

        // persist each product into local DB for offline access with TTL
        for (final p in products) {
          try {
            await _databaseHelper.insertOrUpdateRecord(kProductTable, p.uuid, p.toJson(), ttl: kProductCacheTTL);
          } catch (_) {}
        }

        return products;
      }

      // Fallback: return cached products when network failed
      final cached = await getCachedProducts(categoryCode: categoryCode, farmerId: farmerId);
      if (cached.isNotEmpty) return cached;

      throw Exception('Failed to fetch products');
    } catch (e) {
      // On error return cached products if available
      final cached = await getCachedProducts(categoryCode: categoryCode, farmerId: farmerId);
      if (cached.isNotEmpty) return cached;
      throw _handleError(e);
    }
  }

  Future<Product> getProductByUuid(String uuid) async {
    try {
      final response = await _apiClient.dio.get('/api/products/$uuid/');
      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data as Map<String, dynamic>);
        try {
          await _databaseHelper.insertOrUpdateRecord(kProductTable, uuid, product.toJson(), ttl: kProductCacheTTL);
        } catch (_) {}
        return product;
      }

      // Try cached
      final record = await _databaseHelper.getRecord(kProductTable, uuid);
      if (record != null) return Product.fromJson(record);

      throw Exception('Product not found');
    } catch (e) {
      final record = await _databaseHelper.getRecord(kProductTable, uuid);
      if (record != null) return Product.fromJson(record);
      throw _handleError(e);
    }
  }

  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/api/products/categories/');
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractList(response.data);
        return data.map((json) => ProductCategory.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch categories');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final payload = _buildFormData(data);
      final response = await _apiClient.dio.post('/api/products/farmer/products/', data: payload);
      if (response.statusCode == 201) {
        final product = Product.fromJson(response.data);
        try {
          await _databaseHelper.insertOrUpdateRecord(kProductTable, product.uuid, product.toJson(), ttl: kProductCacheTTL);
        } catch (_) {}
        return product;
      }
      throw Exception('Failed to create product');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> updateProduct(String uuid, Map<String, dynamic> data) async {
    try {
      final payload = _buildFormData(data);
      final response = await _apiClient.dio.patch('/api/products/farmer/products/$uuid/', data: payload);
      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data);
        try {
          await _databaseHelper.insertOrUpdateRecord(kProductTable, uuid, product.toJson(), ttl: kProductCacheTTL);
        } catch (_) {}
        return product;
      }
      throw Exception('Failed to update product');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(String uuid) async {
    try {
      await _apiClient.dio.delete('/api/products/farmer/products/$uuid/');
      try {
        await _databaseHelper.deleteRecord(kProductTable, uuid);
      } catch (_) {}
    } catch (e) {
      throw _handleError(e);
    }
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) {
      return responseData;
    }
    if (responseData is Map<String, dynamic>) {
      final candidates = ['results', 'data', 'products', 'items', 'orders'];
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

  FormData _buildFormData(Map<String, dynamic> data) {
    final formData = FormData();

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == null) continue;
      if (value is File) {
        formData.files.add(MapEntry(
          key,
          MultipartFile.fromFileSync(
            value.path,
            filename: value.path.split(Platform.pathSeparator).last,
          ),
        ));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    }

    return formData;
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null && data['detail'] != null) return data['detail'];
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}