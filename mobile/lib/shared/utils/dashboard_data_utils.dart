import '../../data/models/order.dart';
import '../../data/models/product.dart';

List<Map<String, String>> buildNearbyFarmers(List<Product> products) {
  final seen = <String>{};
  return products
      .where((product) => product.farmerName.isNotEmpty)
      .fold<List<Map<String, String>>>([], (result, product) {
        final key = product.farmerName.toLowerCase();
        if (seen.contains(key)) {
          return result;
        }
        seen.add(key);
        final distanceLabel = product.distanceKm != null
            ? '${product.distanceKm!.toStringAsFixed(1)} km'
            : 'Nearby';
        result.add({
          'name': product.farmerName,
          'location': product.location ?? 'Kenya',
          'distance': distanceLabel,
          'image': product.imageUrl ?? '',
        });
        return result;
      })
      .take(4)
      .toList();
}

double calculateFarmerRevenue(List<SubOrder> subOrders) {
  return subOrders
      .where((subOrder) => subOrder.status.toLowerCase() == 'confirmed')
      .fold<double>(0, (sum, subOrder) => sum + subOrder.subtotal);
}

int countReadySubOrders(List<SubOrder> subOrders) {
  return subOrders.where((subOrder) => subOrder.status.toLowerCase() == 'ready').length;
}
