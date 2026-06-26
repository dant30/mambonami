import 'route_paths.dart';

class AppRole {
  static const buyer = 'buyer';
  static const retailer = 'retailer';
  static const farmer = 'farmer';
  static const transportProvider = 'transport_provider';
  static const admin = 'admin';

  static const buyerRoles = [buyer, retailer];
  static const farmerRoles = [farmer];
  static const transportProviderRoles = [transportProvider];
  static const operationalRoles = [buyer, retailer, farmer, transportProvider];
  static const allRoles = [buyer, retailer, farmer, transportProvider, admin];

  static String homePathFor(String? role) {
    switch (role) {
      case buyer:
      case retailer:
        return RoutePaths.buyerDashboard;
      case farmer:
        return RoutePaths.farmerDashboard;
      case transportProvider:
        return RoutePaths.transportProviderDashboard;
      case admin:
        return '/admin';
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
      case admin:
        return 'Admin';
      default:
        return 'Guest';
    }
  }
}
