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
  final DateTime scheduledDate;
  final String scheduledTimeWindow;
  final String? assignedProviderName;
  final List<SubOrder> subOrders;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.uuid,
    required this.totalAmount,
    required this.deliveryFee,
    required this.platformCommission,
    required this.status,
    this.accountNumber,
    required this.deliveryAddress,
    required this.scheduledDate,
    required this.scheduledTimeWindow,
    this.assignedProviderName,
    required this.subOrders,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      totalAmount: parseDouble(json['total_amount']),
      deliveryFee: parseDouble(json['delivery_fee']),
      platformCommission: parseDouble(json['platform_commission']),
      status: parseString(json['status']),
      accountNumber: json['account_number'] != null ? parseString(json['account_number']) : null,
      deliveryAddress: parseString(json['delivery_address']),
      scheduledDate: parseDate(json['scheduled_date']),
      scheduledTimeWindow: parseString(json['scheduled_time_window']),
      assignedProviderName: _parseAssignedProviderName(json),
      subOrders: parseSubOrders(json['sub_orders']),
      createdAt: parseDate(json['created_at']),
    );
  }

  bool get isPaid => status == 'paid_escrow';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

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
  final DateTime? confirmedAt;
  final DateTime? readyAt;

  const SubOrder({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.status,
    required this.subtotal,
    required this.items,
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
      confirmedAt: json['confirmed_at'] != null ? parseDate(json['confirmed_at']) : null,
      readyAt: json['ready_at'] != null ? parseDate(json['ready_at']) : null,
    );
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isReady => status == 'ready';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [id, status];
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
  if (value is String) return DateTime.parse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  throw FormatException('Unable to parse date: $value');
}

List<SubOrder> parseSubOrders(dynamic value) {
  if (value is List) {
    return value.map((item) => SubOrder.fromJson(item as Map<String, dynamic>)).toList();
  }
  if (value is Map<String, dynamic>) {
    final nested = value['results'] ?? value['data'] ?? [];
    return parseSubOrders(nested);
  }
  return [];
}

List<OrderItem> parseOrderItems(dynamic value) {
  if (value is List) {
    return value.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList();
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
