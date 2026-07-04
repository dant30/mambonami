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
  notifications,
  orderHistory,
  login,
  farmerProductList,
  farmerOrderRequests,
  farmerEarnings,
  cart,
  profile,
  settings,
  support,
  transportAvailableOrders,
  transportMyTrips,
  transportEarnings,
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
      case DeepLinkType.notifications:
        return RoutePaths.notifications;
      case DeepLinkType.orderHistory:
        return RoutePaths.orders;
      case DeepLinkType.login:
        return RoutePaths.login;
      case DeepLinkType.cart:
        return RoutePaths.cart;
      case DeepLinkType.farmerProductList:
        return RoutePaths.farmerProducts;
      case DeepLinkType.farmerOrderRequests:
        return RoutePaths.farmerOrderRequests;
      case DeepLinkType.farmerEarnings:
        return RoutePaths.farmerEarnings;
      case DeepLinkType.profile:
        return RoutePaths.profile;
      case DeepLinkType.settings:
        return RoutePaths.settings;
      case DeepLinkType.support:
        return RoutePaths.support;
      case DeepLinkType.transportAvailableOrders:
        return RoutePaths.availableOrders;
      case DeepLinkType.transportMyTrips:
        return RoutePaths.myTrips;
      case DeepLinkType.transportEarnings:
        return RoutePaths.transportEarnings;
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

    // Route farmer order requests list: /farmer/order-requests
    if (pathSegments.length == 2 &&
        pathSegments[0] == 'farmer' &&
        pathSegments[1] == 'order-requests') {
      debugPrint('[DeepLinkHandler] Detected farmer order requests');
      return DeepLinkInfo(
        type: DeepLinkType.farmerOrderRequests,
        params: uri.queryParameters,
      );
    }

    // Route farmer earnings: /farmer/earnings
    if (pathSegments.length == 2 &&
        pathSegments[0] == 'farmer' &&
        pathSegments[1] == 'earnings') {
      debugPrint('[DeepLinkHandler] Detected farmer earnings');
      return DeepLinkInfo(
        type: DeepLinkType.farmerEarnings,
        params: uri.queryParameters,
      );
    }

    // Route transport list pages. Support both canonical app routes and
    // notification-friendly aliases from the product spec.
    if (pathSegments.length == 2 &&
        (pathSegments[0] == 'transport_provider' ||
            pathSegments[0] == 'transport')) {
      if (pathSegments[1] == 'available-orders' ||
          pathSegments[1] == 'available') {
        debugPrint('[DeepLinkHandler] Detected available orders');
        return DeepLinkInfo(
          type: DeepLinkType.transportAvailableOrders,
          params: uri.queryParameters,
        );
      }
      if (pathSegments[1] == 'my-trips' || pathSegments[1] == 'trips') {
        debugPrint('[DeepLinkHandler] Detected my trips');
        return DeepLinkInfo(
          type: DeepLinkType.transportMyTrips,
          params: uri.queryParameters,
        );
      }
      if (pathSegments[1] == 'earnings') {
        debugPrint('[DeepLinkHandler] Detected transport earnings');
        return DeepLinkInfo(
          type: DeepLinkType.transportEarnings,
          params: uri.queryParameters,
        );
      }
    }

    // Route order tracking: /order/uuid, /orders/uuid, or
    // /buyer/orders/uuid/track.
    if (pathSegments.length >= 4 &&
        pathSegments[0] == 'buyer' &&
        pathSegments[1] == 'orders' &&
        pathSegments[3] == 'track') {
      final uuid = pathSegments[2];
      debugPrint('[DeepLinkHandler] Detected buyer order tracking: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.orderTracking,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route order tracking: /order/uuid or /orders/uuid
    if (pathSegments.length >= 2 &&
        (pathSegments[0] == 'orders' || pathSegments[0] == 'order')) {
      final uuid = pathSegments[1];
      debugPrint('[DeepLinkHandler] Detected order tracking: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.orderTracking,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route order history: /orders
    if (pathSegments.length == 1 && pathSegments[0] == 'orders') {
      debugPrint('[DeepLinkHandler] Detected order history');
      return DeepLinkInfo(
        type: DeepLinkType.orderHistory,
        params: uri.queryParameters,
      );
    }

    // Route product details: /product/uuid or /products/uuid
    if (pathSegments.length >= 2 &&
        (pathSegments[0] == 'products' || pathSegments[0] == 'product')) {
      final uuid = pathSegments[1];
      debugPrint('[DeepLinkHandler] Detected product detail: $uuid');
      return DeepLinkInfo(
        type: DeepLinkType.productDetail,
        uuid: uuid,
        params: uri.queryParameters,
      );
    }

    // Route product catalog: /products or /product
    if (pathSegments.length == 1 &&
        (pathSegments[0] == 'products' || pathSegments[0] == 'product')) {
      debugPrint('[DeepLinkHandler] Detected product catalog');
      return DeepLinkInfo(
          type: DeepLinkType.productCatalog, params: uri.queryParameters);
    }

    // Route notifications: /notifications
    if (pathSegments.length == 1 && pathSegments[0] == 'notifications') {
      debugPrint('[DeepLinkHandler] Detected notifications');
      return DeepLinkInfo(
        type: DeepLinkType.notifications,
        params: uri.queryParameters,
      );
    }

    // Route login: /login
    if (pathSegments.length == 1 && pathSegments[0] == 'login') {
      debugPrint('[DeepLinkHandler] Detected login deep link');
      return DeepLinkInfo(type: DeepLinkType.login);
    }

    // Route cart: /cart
    if (pathSegments.length == 1 && pathSegments[0] == 'cart') {
      debugPrint('[DeepLinkHandler] Detected cart');
      return DeepLinkInfo(type: DeepLinkType.cart, params: uri.queryParameters);
    }

    // Route common account/support pages.
    if (pathSegments.length == 1 && pathSegments[0] == 'profile') {
      debugPrint('[DeepLinkHandler] Detected profile');
      return DeepLinkInfo(type: DeepLinkType.profile);
    }
    if (pathSegments.length == 1 && pathSegments[0] == 'settings') {
      debugPrint('[DeepLinkHandler] Detected settings');
      return DeepLinkInfo(type: DeepLinkType.settings);
    }
    if (pathSegments.length == 1 && pathSegments[0] == 'support') {
      debugPrint('[DeepLinkHandler] Detected support');
      return DeepLinkInfo(type: DeepLinkType.support);
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

    // Route provider dashboard: /transport_provider or /transport
    if (pathSegments.length == 1 &&
        (pathSegments[0] == 'transport_provider' ||
            pathSegments[0] == 'transport')) {
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

  static DeepLinkInfo? parseNotificationPayload(Map<String, dynamic> data) {
    return parseNotificationData(data) ?? _createDeepLinkFromMetadata(data);
  }

  static DeepLinkInfo? _createDeepLinkFromMetadata(Map<String, dynamic> data) {
    final orderId = extractOrderId(data);
    if (orderId != null && data['type'] == 'farmer_order') {
      debugPrint('[DeepLinkHandler] Creating farmer order deep link: $orderId');
      return DeepLinkInfo(
        type: DeepLinkType.farmerOrderDetail,
        id: orderId.toString(),
        params: data.cast<String, String>(),
      );
    }

    final orderUuid = extractOrderUuid(data);
    if (orderUuid != null && data['type'] == 'order_tracking') {
      return DeepLinkInfo(
        type: DeepLinkType.orderTracking,
        uuid: orderUuid,
        params: data.cast<String, String>(),
      );
    }

    return null;
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
