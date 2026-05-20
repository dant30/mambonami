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
    return ProductCategory(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      baseUnit: json['base_unit'],
      isActive: json['is_active'],
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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
      isActive: json['is_active'],
      imageUrl: json['image'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get displayName => variety != null && variety!.isNotEmpty ? '$name ($variety)' : name;
}