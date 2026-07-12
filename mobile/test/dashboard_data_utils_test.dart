import 'package:flutter_test/flutter_test.dart';
import 'package:mambonami/data/models/order.dart';
import 'package:mambonami/data/models/product.dart';
import 'package:mambonami/shared/utils/dashboard_data_utils.dart';

void main() {
  group('dashboard data helpers', () {
    test('buildNearbyFarmers derives farmer names and locations from products', () {
      final products = <Product>[
        Product(
          id: 1,
          uuid: 'u1',
          farmerId: 10,
          farmerPhone: '0712345678',
          farmerName: 'Njeri Farm',
          category: ProductCategory(id: 1, code: 'veg', name: 'Vegetables', isActive: true),
          name: 'Kales',
          pricePerUnit: 120,
          availableQuantity: 25,
          reservedQuantity: 0,
          unit: 'kg',
          harvestDate: DateTime.now(),
          shelfLifeDays: 3,
          isOrganic: true,
          remainingShelfLife: 3,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          location: 'Kiambu',
          distanceKm: 2.8,
        ),
        Product(
          id: 2,
          uuid: 'u2',
          farmerId: 11,
          farmerPhone: '0723456789',
          farmerName: 'Kiboko Growers',
          category: ProductCategory(id: 2, code: 'fruit', name: 'Fruits', isActive: true),
          name: 'Mangoes',
          pricePerUnit: 90,
          availableQuantity: 40,
          reservedQuantity: 0,
          unit: 'kg',
          harvestDate: DateTime.now(),
          shelfLifeDays: 4,
          isOrganic: false,
          remainingShelfLife: 4,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          location: 'Nakuru',
          distanceKm: 5.2,
        ),
        Product(
          id: 3,
          uuid: 'u3',
          farmerId: 10,
          farmerPhone: '0712345678',
          farmerName: 'Njeri Farm',
          category: ProductCategory(id: 1, code: 'veg', name: 'Vegetables', isActive: true),
          name: 'Spinach',
          pricePerUnit: 80,
          availableQuantity: 12,
          reservedQuantity: 0,
          unit: 'bunch',
          harvestDate: DateTime.now(),
          shelfLifeDays: 2,
          isOrganic: true,
          remainingShelfLife: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          location: 'Kiambu',
          distanceKm: 2.8,
        ),
      ];

      final nearbyFarmers = buildNearbyFarmers(products);

      expect(nearbyFarmers.length, 2);
      expect(nearbyFarmers.first['name'], 'Njeri Farm');
      expect(nearbyFarmers.first['location'], 'Kiambu');
    });

    test('calculateTotalRevenue sums confirmed suborders', () {
      final subOrders = <SubOrder>[
        const SubOrder(
          id: 1,
          farmerId: 10,
          farmerName: 'Njeri Farm',
          status: 'confirmed',
          subtotal: 1250,
          items: [],
        ),
        const SubOrder(
          id: 2,
          farmerId: 11,
          farmerName: 'Kiboko Growers',
          status: 'ready',
          subtotal: 950,
          items: [],
        ),
        const SubOrder(
          id: 3,
          farmerId: 12,
          farmerName: 'Uma Farm',
          status: 'pending',
          subtotal: 500,
          items: [],
        ),
      ];

      expect(calculateFarmerRevenue(subOrders), 1250);
      expect(countReadySubOrders(subOrders), 1);
    });
  });
}
