// Deep Link Handler for Mambonami App.
//
// Supports deep links for direct navigation to app screens without requiring
// navigation history or state.extra. Handles:
// - Farmer order request details: mambonami://farmer/orders/<id>
// - Buyer order tracking: mambonami://orders/<uuid>
// - Product details: mambonami://products/<uuid>
// - Dispute details: mambonami://disputes/<uuid>
//
// Deep links can be triggered from:
// - Firebase Cloud Messaging (push notifications)
// - External URI schemes
// - App links (Android App Links / Universal Links)

import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../config/route_paths.dart';

final getIt = GetIt.instance;

enum DeepLinkType {
  farmerOrderDetail,
  orderTracking,
  productDetail,
  productCatalog,
  farmerProductList,
  disputeDetail,
  farmerDashboard,
  buyerDashboard,
  providerDashboard,
  unknown,
}

class DeepLinkInfo {
  final DeepLinkType type;
  final String? id;
  final String? uuid;
  final Map<String, String> params;

  DeepLinkInfo({
    required this.type,
    this.id,
    this.uuid,
    this.params = const {},
  });

  /// Convert parsed deep link to a router path for navigation
  String? toRoutePath() {
    switch (type) {
      case DeepLinkType.farmerOrderDetail:
        return id != null
            ? RoutePaths.farmerOrderRequestDetailPath(int.parse(id!))
            : null;
      case DeepLinkType.orderTracking:
        return uuid != null ? RoutePaths.orderTrackingPath(uuid!) : null;
      case DeepLinkType.productDetail:
        return uuid != null ? RoutePaths.productDetailPath(uuid!) : null;
      case DeepLinkType.productCatalog:
        return RoutePaths.products;
      case DeepLinkType.farmerProductList:
        return RoutePaths.farmerProducts;
      case DeepLinkType.farmerDashboard:
        return RoutePaths.farmerDashboard;
      case DeepLinkType.buyerDashboard:
        return RoutePaths.buyerDashboard;
      case DeepLinkType.providerDashboard:
        return RoutePaths.transportProviderDashboard;
      case DeepLinkType.disputeDetail:
        return RoutePaths.dispute;
      case DeepLinkType.unknown:
        return null;
    }
  }

  @override
  String toString() => 'DeepLinkInfo(type: $type, id: $id, uuid: $uuid)';
}

class DeepLinkHandler {
  /// Parse a deep link URI and extract routing information
  /// Supports formats:
  /// - mambonami://farmer/orders/123
  /// - mambonami://orders/uuid-string
  /// - mambonami://products/uuid-string
  /// - mambonami://disputes/uuid-string
  /// - mambonami://farmer
  /// - mambonami://buyer
  static DeepLinkInfo parseUri(Uri uri) {
    debugPrint('[DeepLinkHandler] Parsing URI: $uri');

    // Handle scheme validation
    if (uri.scheme.isNotEmpty &&
        uri.scheme != 'mambonami' &&
        uri.scheme != 'http' &&
        uri.scheme != 'https') {
      debugPrint('[DeepLinkHandler] Unsupported scheme: ${uri.scheme}');
      return DeepLinkInfo(type: DeepLinkType.unknown);
    }

    // Custom-scheme links such as mambonami://farmer/orders/123 carry the
    // first route segment in host. Web links carry it in pathSegments.
    final pathSegments = _normalizedSegments(uri);
    debugPrint('[DeepLinkHandler] Path segments: $pathSegments');

    if (pathSegments.isEmpty) {
      return DeepLinkInfo(type: DeepLinkType.unknown);
    }

    // Route farmer order details: /farmer/orders/123
    if (pathSegments.length >= 3 &&
        pathSegments[0] == 'farmer' &&
        pathSegments[1] == 'orders') {
      final id = pathSegments[2];
      if (int.tryParse(id) != null) {
        debugPrint('[DeepLinkHandler] Detected farmer order detail: $id');
        return DeepLinkInfo(
          type: DeepLinkType.farmerOrderDetail,
          id: id,
          params: uri.queryParameters,
        );
      }
    }

    // Route farmer products list: /farmer/products
    if (pathSegments.length == 2 &&
        pathSegments[0] == 'farmer' &&
        pathSegments[1] == 'products') {
      debugPrint('[DeepLinkHandler] Detected farmer product list');
      return DeepLinkInfo(
          type: DeepLinkType.farmerProductList, params: uri.queryParameters);
    }

    // Route order tracking: /orders/uuid
    if (pathSegments.length >= 2 && pathSegments[0] == 'orders') {
      final uuid = pathSegments[1];
      debugPrint('[DeepLinkHandler] Detected order tracking: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.orderTracking,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route product details: /products/uuid
    if (pathSegments.length >= 2 && pathSegments[0] == 'products') {
      final uuid = pathSegments[1];
      debugPrint('[DeepLinkHandler] Detected product detail: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.productDetail,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route product catalog: /products
    if (pathSegments.length == 1 && pathSegments[0] == 'products') {
      debugPrint('[DeepLinkHandler] Detected product catalog');
      return DeepLinkInfo(
          type: DeepLinkType.productCatalog, params: uri.queryParameters);
    }

    // Route dispute details: /disputes/uuid
    if (pathSegments.length >= 2 && pathSegments[0] == 'disputes') {
      final uuid = pathSegments[1];
      debugPrint('[DeepLinkHandler] Detected dispute detail: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.disputeDetail,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route farmer dashboard: /farmer
    if (pathSegments.length == 1 && pathSegments[0] == 'farmer') {
      debugPrint('[DeepLinkHandler] Detected farmer dashboard');
      return DeepLinkInfo(type: DeepLinkType.farmerDashboard);
    }

    // Route buyer dashboard: /buyer
    if (pathSegments.length == 1 && pathSegments[0] == 'buyer') {
      debugPrint('[DeepLinkHandler] Detected buyer dashboard');
      return DeepLinkInfo(type: DeepLinkType.buyerDashboard);
    }

    // Route provider dashboard: /transport_provider
    if (pathSegments.length == 1 && pathSegments[0] == 'transport_provider') {
      debugPrint('[DeepLinkHandler] Detected provider dashboard');
      return DeepLinkInfo(type: DeepLinkType.providerDashboard);
    }

    debugPrint('[DeepLinkHandler] Unknown deep link path: $pathSegments');
    return DeepLinkInfo(type: DeepLinkType.unknown);
  }

  static List<String> _normalizedSegments(Uri uri) {
    final segments = <String>[];
    if (uri.scheme == 'mambonami' && uri.host.isNotEmpty) {
      segments.add(uri.host);
    }
    segments.addAll(uri.pathSegments);
    return segments.where((segment) => segment.isNotEmpty).toList();
  }

  /// Parse a deep link from notification metadata
  /// Expects notification data to contain a 'deepLink' key
  static DeepLinkInfo? parseNotificationData(Map<String, dynamic> data) {
    final deepLinkStr = data['deepLink'] as String?;
    if (deepLinkStr == null || deepLinkStr.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(deepLinkStr);
      return parseUri(uri);
    } catch (e) {
      debugPrint('[DeepLinkHandler] Failed to parse notification deepLink: $e');
      return null;
    }
  }

  /// Extract order ID from notification metadata
  /// Checks for 'order_id', 'suborder_id', 'orderId', 'suborderId' keys
  static int? extractOrderId(Map<String, dynamic> data) {
    final candidates = [
      'order_id',
      'suborder_id',
      'orderId',
      'suborderId',
      'id'
    ];
    for (final key in candidates) {
      final value = data[key];
      if (value != null) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      }
    }
    return null;
  }

  /// Extract order UUID from notification metadata
  static String? extractOrderUuid(Map<String, dynamic> data) {
    final candidates = ['order_uuid', 'orderUuid', 'uuid'];
    for (final key in candidates) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
