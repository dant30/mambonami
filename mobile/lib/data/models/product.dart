// lib/data/models/product.dart
class ProductCategory {
  final int id;
  final String code;
  final String name;
  final String baseUnit;
  final bool isActive;

  ProductCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.baseUnit,
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
      baseUnit: json['base_unit'],
      isActive: parseBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'base_unit': baseUnit,
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
  final double pricePerUnit;
  final double availableQuantity;
  final String unit;
  final DateTime harvestDate;
  final int shelfLifeDays;
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
    required this.pricePerUnit,
    required this.availableQuantity,
    required this.unit,
    required this.harvestDate,
    required this.shelfLifeDays,
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
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
      availableQuantity: double.parse(json['available_quantity'].toString()),
      unit: json['unit'],
      harvestDate: DateTime.parse(json['harvest_date']),
      shelfLifeDays: json['shelf_life_days'],
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

  String get displayName => variety != null && variety!.isNotEmpty ? '$name ($variety)' : name;
}
