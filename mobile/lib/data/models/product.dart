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
    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v == null) return false;
      if (v is num) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    return ProductCategory(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      isActive: parseBool(json['is_active']),
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
    double? parseNullableDouble(dynamic v) {
      if (v == null) return null;
      try {
        return double.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    double parseDoubleDefault(dynamic v, double def) {
      if (v == null) return def;
      try {
        return double.parse(v.toString());
      } catch (_) {
        return def;
      }
    }

    return Product(
      id: json['id'],
      uuid: json['uuid'],
      farmerId: json['farmer'],
      farmerPhone: json['farmer_phone'] ?? '',
      farmerName: json['farmer_name'] ?? '',
      category: ProductCategory.fromJson(json['category_detail']),
      name: json['name'],
      variety: json['variety'],
      sku: json['sku'] != null ? json['sku'].toString() : null,
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      availableQuantity: double.parse(json['available_quantity'].toString()),
      reservedQuantity: parseDoubleDefault(json['reserved_quantity'], 0.0),
      unit: json['unit'],
      harvestDate: DateTime.parse(json['harvest_date']),
      shelfLifeDays: json['shelf_life_days'],
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
      isOrganic: (() {
        final v = json['is_organic'];
        if (v is bool) return v;
        if (v == null) return false;
        if (v is num) return v != 0;
        final s = v.toString().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      })(),
      remainingShelfLife: json['remaining_shelf_life'],
      isActive: (() {
        final v = json['is_active'];
        if (v is bool) return v;
        if (v == null) return false;
        if (v is num) return v != 0;
        final s = v.toString().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      })(),
      imageUrl: json['image'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pickupLat: parseNullableDouble(json['pickup_lat']),
      pickupLng: parseNullableDouble(json['pickup_lng']),
      weightPerUnit: parseDoubleDefault(json['weight_per_unit'], 0.0),
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
