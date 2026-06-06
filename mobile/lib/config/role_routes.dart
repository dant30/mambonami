import 'route_paths.dart';

class AppRole {
  static const buyer = 'buyer';
  static const retailer = 'retailer';
  static const farmer = 'farmer';
  static const transportProvider = 'transport_provider';

  static const buyerRoles = [buyer, retailer];
  static const farmerRoles = [farmer];
  static const transportProviderRoles = [transportProvider];
  static const operationalRoles = [buyer, retailer, farmer, transportProvider];

  static String homePathFor(String? role) {
    switch (role) {
      case buyer:
      case retailer:
        return RoutePaths.buyerDashboard;
      case farmer:
        return RoutePaths.farmerDashboard;
      case transportProvider:
        return RoutePaths.transportProviderDashboard;
      default:
        return RoutePaths.login;
    }
  }

  static bool isHomePathForRole(String path, String role) {
    final homePath = homePathFor(role);
    return homePath != RoutePaths.login &&
        (path == homePath || path.startsWith('$homePath/'));
  }

  static String displayLabel(String? role) {
    switch (role) {
      case buyer:
        return 'Buyer';
      case retailer:
        return 'Retailer';
      case farmer:
        return 'Farmer';
      case transportProvider:
        return 'Transport Provider';
      default:
        return 'Guest';
    }
  }
}
