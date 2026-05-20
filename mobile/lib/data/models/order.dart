// lib/data/models/order.dart
import 'package:equatable/equatable.dart';
import 'product.dart';

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
      id: json['id'],
      uuid: json['uuid'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      platformCommission: (json['platform_commission'] as num).toDouble(),
      status: json['status'],
      accountNumber: json['account_number'],
      deliveryAddress: json['delivery_address'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledTimeWindow: json['scheduled_time_window'],
      assignedProviderName: json['assigned_provider_name'],
      subOrders: (json['sub_orders'] as List).map((e) => SubOrder.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['created_at']),
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
      id: json['id'],
      farmerId: json['farmer_id'],
      farmerName: json['farmer_name'],
      status: json['status'],
      subtotal: (json['subtotal'] as num).toDouble(),
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      readyAt: json['ready_at'] != null ? DateTime.parse(json['ready_at']) : null,
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
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, productName];
}