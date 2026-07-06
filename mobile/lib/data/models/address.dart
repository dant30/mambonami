import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String label;
  final String street;
  final String city;
  final String postalCode;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? phone;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.postalCode,
    this.landmark,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      label: json['label']?.toString() ?? 'Home',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: json['is_default'] is bool
          ? json['is_default'] as bool
          : json['is_default'] is String && (json['is_default'] as String).toLowerCase() == 'true',
      phone: json['phone']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'street': street,
        'city': city,
        'postal_code': postalCode,
        'landmark': landmark,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault,
        'phone': phone,
        'created_at': createdAt.toIso8601String(),
      };

  String get shortAddress {
    final parts = [street, city, postalCode].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get detailedAddress {
    final parts = [street, city, postalCode, landmark].where((part) => part?.isNotEmpty == true).cast<String>().toList();
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, label, street, city, postalCode, landmark, latitude, longitude, isDefault, phone, createdAt];
}
