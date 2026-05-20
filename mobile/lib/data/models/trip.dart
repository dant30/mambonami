class Trip {
  final int id;
  final String uuid;
  final int order;
  final int? provider;
  final String status;
  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? pickupPhoto;
  final String? deliveryPhoto;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.uuid,
    required this.order,
    this.provider,
    required this.status,
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
    this.pickupPhoto,
    this.deliveryPhoto,
    this.pickedUpAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      uuid: json['uuid'],
      order: json['order'],
      provider: json['provider'],
      status: json['status'],
      pickupLat: json['pickup_lat'] != null ? double.parse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.parse(json['pickup_lng'].toString()) : null,
      deliveryLat: json['delivery_lat'] != null ? double.parse(json['delivery_lat'].toString()) : null,
      deliveryLng: json['delivery_lng'] != null ? double.parse(json['delivery_lng'].toString()) : null,
      pickupPhoto: json['pickup_photo'],
      deliveryPhoto: json['delivery_photo'],
      pickedUpAt: json['picked_up_at'] != null ? DateTime.parse(json['picked_up_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'order': order,
        'provider': provider,
        'status': status,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'pickup_photo': pickupPhoto,
        'delivery_photo': deliveryPhoto,
        'picked_up_at': pickedUpAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}