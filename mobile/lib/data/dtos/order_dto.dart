/// Request/Response DTOs for Order API operations
library;

// ============ CREATE ORDER REQUEST ============
class CreateOrderRequest {
  final List<CartItemDto> items;
  final String deliveryAddress;
  final String deliveryStreet;
  final String deliveryCity;
  final String deliveryPostalCode;
  final String? deliveryLandmark;
  final double deliveryLat;
  final double deliveryLng;
  final String scheduledDate;
  final String scheduledTimeWindow;
  final String? paymentMethod;

  CreateOrderRequest({
    required this.items,
    required this.deliveryAddress,
    required this.deliveryStreet,
    required this.deliveryCity,
    required this.deliveryPostalCode,
    this.deliveryLandmark,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.scheduledDate,
    required this.scheduledTimeWindow,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'delivery_street': deliveryStreet,
      'delivery_city': deliveryCity,
      'delivery_postal_code': deliveryPostalCode,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'scheduled_date': scheduledDate,
      'scheduled_time_window': scheduledTimeWindow,
    };

    if (deliveryLandmark != null && deliveryLandmark!.trim().isNotEmpty) {
      payload['delivery_landmark'] = deliveryLandmark;
    }
    if (paymentMethod != null && paymentMethod!.trim().isNotEmpty) {
      payload['payment_method'] = paymentMethod;
    }

    return payload;
  }
}

// ============ CART ITEM DTO ============
class CartItemDto {
  final String productUuid;
  final double quantity;

  CartItemDto({required this.productUuid, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_uuid': productUuid,
    'quantity': quantity,
  };
}

// ============ ORDER RESPONSE ============
class OrderResponse {
  final int id;
  final String uuid;
  final double totalAmount;
  final double deliveryFee;
  final double platformCommission;
  final String status;
  final String? accountNumber;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLng;
  final String deliveryStreet;
  final String deliveryCity;
  final String deliveryPostalCode;
  final String? deliveryLandmark;
  final double totalWeightKg;
  final DateTime scheduledDate;
  final String scheduledTimeWindow;
  final String? assignedProviderName;
  final String? assignedProviderPhone;
  final List<SubOrderResponse> subOrders;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderResponse({
    required this.id,
    required this.uuid,
    required this.totalAmount,
    required this.deliveryFee,
    required this.platformCommission,
    required this.status,
    this.accountNumber,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.deliveryStreet,
    required this.deliveryCity,
    required this.deliveryPostalCode,
    this.deliveryLandmark,
    required this.totalWeightKg,
    required this.scheduledDate,
    required this.scheduledTimeWindow,
    this.assignedProviderName,
    this.assignedProviderPhone,
    required this.subOrders,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      platformCommission: (json['platform_commission'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      accountNumber: json['account_number'],
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryLat: (json['delivery_lat'] ?? json['delivery_latitude'] ?? 0.0).toDouble(),
      deliveryLng: (json['delivery_lng'] ?? json['delivery_longitude'] ?? 0.0).toDouble(),
      deliveryStreet: json['delivery_street'] ?? '',
      deliveryCity: json['delivery_city'] ?? '',
      deliveryPostalCode: json['delivery_postal_code'] ?? '',
      deliveryLandmark: json['delivery_landmark'],
      totalWeightKg: (json['total_weight_kg'] ?? 0.0).toDouble(),
      scheduledDate: DateTime.tryParse(json['scheduled_date'] ?? '') ?? DateTime.now(),
      scheduledTimeWindow: json['scheduled_time_window'] ?? '',
      assignedProviderName: json['assigned_provider_name'],
      assignedProviderPhone: json['assigned_provider_phone'],
      subOrders: _parseSubOrders(json['sub_orders'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  static List<SubOrderResponse> _parseSubOrders(dynamic subOrdersData) {
    if (subOrdersData is! List) return [];
    return subOrdersData
        .whereType<Map<String, dynamic>>()
        .map((json) => SubOrderResponse.fromJson(json))
        .toList();
  }
}

// ============ SUB-ORDER RESPONSE ============
class SubOrderResponse {
  final int id;
  final int farmerId;
  final String farmerName;
  final String farmerPhone;
  final String status;
  final double subtotal;
  final List<OrderItemResponse> items;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  SubOrderResponse({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.status,
    required this.subtotal,
    required this.items,
    this.confirmedAt,
    this.readyAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory SubOrderResponse.fromJson(Map<String, dynamic> json) {
    return SubOrderResponse(
      id: json['id'] ?? 0,
      farmerId: json['farmer'] ?? json['farmer_id'] ?? 0,
      farmerName: _parseFarmerName(json),
      farmerPhone: json['farmer_phone'] ?? '',
      status: json['status'] ?? 'pending',
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      items: _parseOrderItems(json['items'] ?? []),
      confirmedAt: json['confirmed_at'] != null ? DateTime.tryParse(json['confirmed_at']) : null,
      readyAt: json['ready_at'] != null ? DateTime.tryParse(json['ready_at']) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at']) : null,
    );
  }

  static String _parseFarmerName(Map<String, dynamic> json) {
    if (json['farmer_name'] is String) return json['farmer_name'];
    if (json['farmer'] is Map) {
      final farmer = json['farmer'] as Map<String, dynamic>;
      return farmer['name'] ?? farmer['full_name'] ?? '';
    }
    return '';
  }

  static List<OrderItemResponse> _parseOrderItems(dynamic itemsData) {
    if (itemsData is! List) return [];
    return itemsData
        .whereType<Map<String, dynamic>>()
        .map((json) => OrderItemResponse.fromJson(json))
        .toList();
  }
}

// ============ ORDER ITEM RESPONSE ============
class OrderItemResponse {
  final int id;
  final String productUuid;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalPrice;

  OrderItemResponse({
    required this.id,
    required this.productUuid,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: json['id'] ?? 0,
      productUuid: json['product_uuid'] ?? json['product'] ?? '',
      productName: _parseProductName(json),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      pricePerUnit: (json['price_per_unit'] ?? 0.0).toDouble(),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
    );
  }

  static String _parseProductName(Map<String, dynamic> json) {
    if (json['product_name'] is String) return json['product_name'];
    if (json['product'] is Map) {
      final product = json['product'] as Map<String, dynamic>;
      return product['name'] ?? '';
    }
    return '';
  }
}

// ============ GENERATE OTP REQUEST ============
class GenerateOTPRequest {
  final String tripUuid;

  GenerateOTPRequest({required this.tripUuid});

  Map<String, dynamic> toJson() => {
    'trip_uuid': tripUuid,
  };
}

// ============ VERIFY OTP REQUEST ============
class VerifyOTPRequest {
  final String tripUuid;
  final String otp;
  final String? buyerPhone;

  VerifyOTPRequest({
    required this.tripUuid,
    required this.otp,
    this.buyerPhone,
  });

  Map<String, dynamic> toJson() => {
    'trip_uuid': tripUuid,
    'otp': otp,
    if (buyerPhone != null) 'buyer_phone': buyerPhone,
  };
}

// ============ VERIFY OTP RESPONSE ============
class VerifyOTPResponse {
  final bool isValid;
  final String message;
  final String? tripStatus;
  final DateTime? verifiedAt;

  VerifyOTPResponse({
    required this.isValid,
    required this.message,
    this.tripStatus,
    this.verifiedAt,
  });

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      isValid: json['is_valid'] ?? false,
      message: json['message'] ?? 'OTP verification failed',
      tripStatus: json['trip_status'] ?? json['status'],
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at']) : null,
    );
  }
}
