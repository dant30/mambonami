// lib/data/models/order.dart
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String uuid;
  final double totalAmount;
  final double deliveryFee;
  final double platformCommission;
  final String status;
  final String? accountNumber;
  final String deliveryAddress;
  final String deliveryStreet;
  final String deliveryCity;
  final String deliveryPostalCode;
  final String deliveryLandmark;
  final double deliveryLat;
  final double deliveryLng;
  final double totalWeightKg;
  final DateTime scheduledDate;
  final String scheduledTimeWindow;
  final String? assignedProviderName;
  final String? buyerName;
  final String? buyerPhone;
  final String? paybillNumber;
  final DateTime? paymentExpiresAt;
  final String? paymentReference;
  final List<String> timeline;
  final List<SubOrder> subOrders;
  final DateTime createdAt;
  final double? totalDistanceKm;
  final int? etaMinutes;
  final String? providerPhotoUrl;
  final String? providerVehicle;
  final String? providerPhone;
  final double? providerRating;

  const Order({
    required this.id,
    required this.uuid,
    required this.totalAmount,
    required this.deliveryFee,
    required this.platformCommission,
    required this.status,
    this.accountNumber,
    required this.deliveryAddress,
    required this.deliveryStreet,
    required this.deliveryCity,
    required this.deliveryPostalCode,
    required this.deliveryLandmark,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.totalWeightKg,
    required this.scheduledDate,
    required this.scheduledTimeWindow,
    this.assignedProviderName,
    this.buyerName,
    this.buyerPhone,
    this.paybillNumber,
    this.paymentExpiresAt,
    this.paymentReference,
    this.timeline = const [],
    required this.subOrders,
    required this.createdAt,
    this.totalDistanceKm,
    this.etaMinutes,
    this.providerPhotoUrl,
    this.providerVehicle,
    this.providerPhone,
    this.providerRating,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final street = parseString(json['delivery_street']);
    final city = parseString(json['delivery_city']);
    final postal = parseString(json['delivery_postal_code']);
    final landmark = parseString(json['delivery_landmark']);
    final combinedAddress = street.isNotEmpty
        ? [street, city, postal].where((section) => section.isNotEmpty).join(', ') + (landmark.isNotEmpty ? ' • $landmark' : '')
        : parseString(json['delivery_address']);

    return Order(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      totalAmount: parseDouble(json['total_amount']),
      deliveryFee: parseDouble(json['delivery_fee']),
      platformCommission: parseDouble(json['platform_commission']),
      status: parseString(json['status']),
      accountNumber: json['account_number'] != null ? parseString(json['account_number']) : null,
      deliveryAddress: combinedAddress,
      deliveryStreet: street,
      deliveryCity: city,
      deliveryPostalCode: postal,
      deliveryLandmark: landmark,
      deliveryLat: parseDouble(json['delivery_lat'] ?? json['delivery_latitude']),
      deliveryLng: parseDouble(json['delivery_lng'] ?? json['delivery_longitude']),
      totalWeightKg: parseDouble(json['total_weight_kg']),
      scheduledDate: parseDate(json['scheduled_date']),
      scheduledTimeWindow: parseString(json['scheduled_time_window']),
      assignedProviderName: _parseAssignedProviderName(json),
      buyerName: parseString(json['buyer_name'] ?? json['buyerName']),
      buyerPhone: parseString(json['buyer_phone'] ?? json['buyerPhone']),
      paybillNumber: parseString(json['paybill_number'] ?? json['paybillNumber']),
      paymentExpiresAt: json['payment_expires_at'] != null ? parseDate(json['payment_expires_at']) : null,
      paymentReference: parseString(json['payment_reference'] ?? json['paymentReference']),
      timeline: _parseTimeline(json['timeline'] ?? json['status_steps'] ?? json['timeline_steps']),
      subOrders: parseSubOrders(json['sub_orders']),
      createdAt: parseDate(json['created_at']),
      totalDistanceKm: parseDouble(json['total_distance_km'] ?? json['distance_km']).isFinite ? parseDouble(json['total_distance_km'] ?? json['distance_km']) : null,
      etaMinutes: parseInt(json['eta_minutes'] ?? json['eta']).isFinite ? parseInt(json['eta_minutes'] ?? json['eta']) : null,
      providerPhotoUrl: _parseProviderPhotoUrl(json),
      providerVehicle: _parseProviderVehicle(json),
      providerPhone: _parseProviderPhone(json),
      providerRating: parseDouble(json['provider_rating']).isFinite ? parseDouble(json['provider_rating']) : null,
    );
  }

  bool get isPaid => status == 'paid_escrow';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'paid_escrow':
        return 'Paid';
      case 'transport_assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked Up';
      default:
        return 'Processing';
    }
  }

  String get createdAtLabel => createdAt.toLocal().toString().split(' ').first;
  String get itemsSummary => subOrders.expand((subOrder) => subOrder.items).map((item) => item.productName).join(', ');
  double get total => totalAmount;

  @override
  List<Object?> get props => [id, uuid, status];
}

class SubOrder extends Equatable {
  final int id;
  final int farmerId;
  final String farmerName;
  final String status;
  final double subtotal;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? readyAt;

  const SubOrder({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.status,
    required this.subtotal,
    required this.items,
    this.createdAt,
    this.confirmedAt,
    this.readyAt,
  });

  factory SubOrder.fromJson(Map<String, dynamic> json) {
    return SubOrder(
      id: parseInt(json['id']),
      farmerId: parseInt(json['farmer'] ?? json['farmer_id']),
      farmerName: _parseFarmerName(json),
      status: parseString(json['status']),
      subtotal: parseDouble(json['subtotal']),
      items: parseOrderItems(json['items']),
      createdAt: json['created_at'] != null ? parseDate(json['created_at']) : null,
      confirmedAt: json['confirmed_at'] != null ? parseDate(json['confirmed_at']) : null,
      readyAt: json['ready_at'] != null ? parseDate(json['ready_at']) : null,
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isReady => status == 'ready';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [id, status, createdAt];
}

class OrderItem extends Equatable {
  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: parseInt(json['product'] ?? json['product_id']),
      productName: _parseProductName(json),
      quantity: parseDouble(json['quantity']),
      unitPrice: parseDouble(json['unit_price']),
      totalPrice: parseDouble(json['total_price']),
    );
  }

  @override
  List<Object?> get props => [productId, productName];
}

String parseString(dynamic value) {
  if (value is String) return value;
  if (value == null) return '';
  return value.toString();
}

int parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

double parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value == null) return 0.0;
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}

List<SubOrder> parseSubOrders(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().map(SubOrder.fromJson).toList();
  }
  if (value is Map<String, dynamic>) {
    final nested = value['results'] ?? value['data'] ?? [];
    return parseSubOrders(nested);
  }
  return [];
}

List<OrderItem> parseOrderItems(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().map(OrderItem.fromJson).toList();
  }
  if (value is Map<String, dynamic>) {
    final nested = value['results'] ?? value['data'] ?? [];
    return parseOrderItems(nested);
  }
  return [];
}

String _parseFarmerName(Map<String, dynamic> json) {
  final farmerName = parseString(json['farmer_name']);
  if (farmerName.isNotEmpty) return farmerName;

  final farmerPhone = parseString(json['farmer_phone']);
  if (farmerPhone.isNotEmpty) return 'Farmer $farmerPhone';

  if (json['farmer'] != null) return 'Farmer ${parseString(json['farmer'])}';

  return 'Unknown farmer';
}

String _parseProductName(Map<String, dynamic> json) {
  final productDetail = json['product_detail'];
  if (productDetail is Map<String, dynamic>) {
    final name = parseString(productDetail['name']);
    if (name.isNotEmpty) return name;
  }

  final fallback = parseString(json['product_name']);
  if (fallback.isNotEmpty) return fallback;

  return parseString(json['product']);
}

String? _parseAssignedProviderName(Map<String, dynamic> json) {
  final assignedProviderName = parseString(json['assigned_provider_name']);
  if (assignedProviderName.isNotEmpty) return assignedProviderName;

  final assignedProvider = json['assigned_provider'];
  if (assignedProvider is Map<String, dynamic>) {
    final name = parseString(assignedProvider['name']);
    if (name.isNotEmpty) return name;

    final uuid = parseString(assignedProvider['uuid']);
    if (uuid.isNotEmpty) return uuid;

    final phone = parseString(assignedProvider['phone']);
    if (phone.isNotEmpty) return phone;
  }

  if (assignedProvider != null) return assignedProvider.toString();
  return null;
}

String? _parseProviderPhotoUrl(Map<String, dynamic> json) {
  final assignedProvider = json['assigned_provider'];
  final direct = parseString(json['provider_photo_url'] ?? json['provider_photo']);
  if (direct.isNotEmpty) return direct;
  if (assignedProvider is Map<String, dynamic>) {
    final photo = parseString(assignedProvider['photo_url'] ?? assignedProvider['photo']);
    if (photo.isNotEmpty) return photo;
  }
  return null;
}

String? _parseProviderVehicle(Map<String, dynamic> json) {
  final assignedProvider = json['assigned_provider'];
  final direct = parseString(json['provider_vehicle'] ?? json['vehicle']);
  if (direct.isNotEmpty) return direct;
  if (assignedProvider is Map<String, dynamic>) {
    final vehicle = parseString(assignedProvider['vehicle']);
    if (vehicle.isNotEmpty) return vehicle;
  }
  return null;
}

String? _parseProviderPhone(Map<String, dynamic> json) {
  final assignedProvider = json['assigned_provider'];
  final direct = parseString(json['provider_phone'] ?? json['phone']);
  if (direct.isNotEmpty) return direct;
  if (assignedProvider is Map<String, dynamic>) {
    final phone = parseString(assignedProvider['phone']);
    if (phone.isNotEmpty) return phone;
  }
  return null;
}

List<String> _parseTimeline(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return [];
}