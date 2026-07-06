// mobile/lib/data/models/trip.dart
class Trip {
  final int id;
  final String uuid;
  final int order;
  final double? agreedFee;
  final double? waitingSurcharge;
  final int? provider;
  final String status;
  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? currentLat;
  final double? currentLng;
  final String? pickupPhoto;
  final String? deliveryPhoto;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleType;
  final String? vehiclePlate;
  final int? etaMinutes;
  final double? distanceKm;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.uuid,
    required this.order,
    this.agreedFee,
    this.waitingSurcharge,
    this.provider,
    required this.status,
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
    this.currentLat,
    this.currentLng,
    this.pickupPhoto,
    this.deliveryPhoto,
    this.driverName,
    this.driverPhone,
    this.vehicleType,
    this.vehiclePlate,
    this.etaMinutes,
    this.distanceKm,
    this.pickedUpAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      order: json['order'] is int ? json['order'] : int.tryParse(json['order']?.toString() ?? '') ?? 0,
      agreedFee: json['agreed_fee'] != null ? double.tryParse(json['agreed_fee'].toString()) : null,
      waitingSurcharge: json['waiting_surcharge'] != null ? double.tryParse(json['waiting_surcharge'].toString()) : null,
      provider: json['provider'] is int ? json['provider'] : int.tryParse(json['provider']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'pending',
      pickupLat: json['pickup_lat'] != null ? double.tryParse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.tryParse(json['pickup_lng'].toString()) : null,
      deliveryLat: json['delivery_lat'] != null ? double.tryParse(json['delivery_lat'].toString()) : null,
      deliveryLng: json['delivery_lng'] != null ? double.tryParse(json['delivery_lng'].toString()) : null,
      currentLat: json['current_lat'] != null ? double.tryParse(json['current_lat'].toString()) : null,
      currentLng: json['current_lng'] != null ? double.tryParse(json['current_lng'].toString()) : null,
      pickupPhoto: json['pickup_photo']?.toString(),
      deliveryPhoto: json['delivery_photo']?.toString(),
      driverName: json['driver_name']?.toString() ?? json['driverName']?.toString(),
      driverPhone: json['driver_phone']?.toString() ?? json['driverPhone']?.toString(),
      vehicleType: json['vehicle_type']?.toString() ?? json['vehicleType']?.toString(),
      vehiclePlate: json['vehicle_plate']?.toString() ?? json['vehiclePlate']?.toString(),
      etaMinutes: json['eta_minutes'] is int ? json['eta_minutes'] : int.tryParse(json['eta_minutes']?.toString() ?? ''),
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'order': order,
        if (agreedFee != null) 'agreed_fee': agreedFee,
        if (waitingSurcharge != null) 'waiting_surcharge': waitingSurcharge,
        'provider': provider,
        'status': status,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'current_lat': currentLat,
        'current_lng': currentLng,
        'pickup_photo': pickupPhoto,
        'delivery_photo': deliveryPhoto,
        'driver_name': driverName,
        'driver_phone': driverPhone,
        'vehicle_type': vehicleType,
        'vehicle_plate': vehiclePlate,
        'eta_minutes': etaMinutes,
        'distance_km': distanceKm,
        'picked_up_at': pickedUpAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
