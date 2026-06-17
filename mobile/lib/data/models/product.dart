// lib/data/models/product.dart
class ProductCategory {
  final int id;
  final String code;
  final String name;
  final bool isActive;

  ProductCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: _parseBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'is_active': isActive,
  };
}

class Product {
  final int id;
  final String uuid;
  final int farmerId;
  final String farmerPhone;
  final String farmerName;
  final ProductCategory category;
  final String name;
  final String? variety;
  final String? sku;
  final double pricePerUnit;
  final double availableQuantity;
  final double reservedQuantity;
  final String unit;
  final DateTime harvestDate;
  final int shelfLifeDays;
  final DateTime? expiryDate;
  final bool isOrganic;
  final int remainingShelfLife;
  final bool isActive;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? pickupLat;
  final double? pickupLng;
  final double weightPerUnit;

  Product({
    required this.id,
    required this.uuid,
    required this.farmerId,
    required this.farmerPhone,
    required this.farmerName,
    required this.category,
    required this.name,
    this.variety,
    this.sku,
    required this.pricePerUnit,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.unit,
    required this.harvestDate,
    required this.shelfLifeDays,
    this.expiryDate,
    required this.isOrganic,
    required this.remainingShelfLife,
    required this.isActive,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.pickupLat,
    this.pickupLng,
    this.weightPerUnit = 0.0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      farmerId: json['farmer'] is int ? json['farmer'] : int.tryParse(json['farmer']?.toString() ?? '') ?? 0,
      farmerPhone: json['farmer_phone']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? '',
      category: ProductCategory.fromJson(json['category_detail'] is Map<String, dynamic> ? json['category_detail'] as Map<String, dynamic> : const {}),
      name: json['name']?.toString() ?? '',
      variety: json['variety']?.toString(),
      sku: json['sku'] != null ? json['sku'].toString() : null,
      pricePerUnit: _parseDouble(json['price_per_unit']),
      availableQuantity: _parseDouble(json['available_quantity']),
      reservedQuantity: _parseDouble(json['reserved_quantity']),
      unit: json['unit']?.toString() ?? '',
      harvestDate: DateTime.tryParse(json['harvest_date']?.toString() ?? '') ?? DateTime.now(),
      shelfLifeDays: json['shelf_life_days'] is int ? json['shelf_life_days'] : int.tryParse(json['shelf_life_days']?.toString() ?? '') ?? 0,
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
      isOrganic: _parseBool(json['is_organic']),
      remainingShelfLife: json['remaining_shelf_life'] is int ? json['remaining_shelf_life'] : int.tryParse(json['remaining_shelf_life']?.toString() ?? '') ?? 0,
      isActive: _parseBool(json['is_active']),
      imageUrl: json['image']?.toString(),
      description: json['description']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      pickupLat: _parseNullableDouble(json['pickup_lat']),
      pickupLng: _parseNullableDouble(json['pickup_lng']),
      weightPerUnit: _parseDouble(json['weight_per_unit']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'farmer': farmerId,
    'farmer_phone': farmerPhone,
    'farmer_name': farmerName,
    'category_detail': category.toJson(),
    'name': name,
    'variety': variety,
    'sku': sku,
    'price_per_unit': pricePerUnit,
    'available_quantity': availableQuantity,
    'reserved_quantity': reservedQuantity,
    'unit': unit,
    'harvest_date': harvestDate.toIso8601String(),
    'shelf_life_days': shelfLifeDays,
    'expiry_date': expiryDate?.toIso8601String(),
    'is_organic': isOrganic,
    'remaining_shelf_life': remainingShelfLife,
    'is_active': isActive,
    'image': imageUrl,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'pickup_lat': pickupLat,
    'pickup_lng': pickupLng,
    'weight_per_unit': weightPerUnit,
  };

  String get displayName => variety != null && variety!.isNotEmpty ? '$name ($variety)' : name;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value == null) return false;
  if (value is num) return value != 0;
  final normalized = value.toString().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

double _parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}
