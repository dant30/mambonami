import 'package:flutter_test/flutter_test.dart';
import 'package:mambonami/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses serializer fields from the current backend payload', () {
      final product = Product.fromJson({
        'id': 1,
        'uuid': 'abc123',
        'farmer': 2,
        'farmer_phone': '0700000000',
        'farmer_name': 'Grace',
        'farmer_verified': true,
        'farmer_rating': 4.8,
        'category_detail': {'id': 1, 'code': 'veg', 'name': 'Vegetables'},
        'name': 'Tomatoes',
        'price_per_unit': 100.0,
        'available_quantity': 12.0,
        'reserved_quantity': 3.0,
        'unit': 'kg',
        'harvest_date': '2024-01-01',
        'shelf_life_days': 3,
        'is_organic': true,
        'remaining_shelf_life': 2,
        'is_active': true,
        'image_url': 'https://cdn.example.com/tomatoes.jpg',
        'description': 'Fresh produce',
        'rating': 4.5,
        'review_count': 10,
        'wishlist_count': 3,
        'created_at': '2024-01-02T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
        'pickup_lat': -1.0,
        'pickup_lng': 36.0,
        'weight_per_unit': 1.0,
      });

      expect(product.imageUrl, 'https://cdn.example.com/tomatoes.jpg');
      expect(product.farmerVerified, isTrue);
      expect(product.averageRating, 4.5);
      expect(product.reviewCount, 10);
      expect(product.wishlistCount, 3);
    });
  });
}
