// // mobile/lib/shared/layouts/app_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../config/route_paths.dart';
import '../../config/role_routes.dart';
import 'bottom_nav_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  int _selectedIndex(String location) {
    final normalizedLocation = location.split('?').first;
    if (normalizedLocation == RoutePaths.buyerDashboard ||
        normalizedLocation == RoutePaths.farmerDashboard ||
        normalizedLocation == RoutePaths.transportProviderDashboard ||
        normalizedLocation.startsWith('${RoutePaths.buyerDashboard}/') ||
        normalizedLocation.startsWith('${RoutePaths.farmerDashboard}/') ||
        normalizedLocation.startsWith('${RoutePaths.transportProviderDashboard}/')) {
      return 0;
    }
    if (normalizedLocation == RoutePaths.products ||
        normalizedLocation.startsWith('${RoutePaths.products}/') ||
        normalizedLocation == RoutePaths.productCatalog ||
        normalizedLocation.startsWith('${RoutePaths.productCatalog}/')) {
      return 1;
    }
    if (normalizedLocation == RoutePaths.orders ||
        normalizedLocation.startsWith('${RoutePaths.orders}/') ||
        normalizedLocation == RoutePaths.orderHistory ||
        normalizedLocation.startsWith('${RoutePaths.orderHistory}/')) {
      return 2;
    }
    if (normalizedLocation == RoutePaths.wishlist ||
        normalizedLocation.startsWith('${RoutePaths.wishlist}/')) {
      return 3;
    }
    if (normalizedLocation == RoutePaths.profile ||
        normalizedLocation.startsWith('${RoutePaths.profile}/')) {
      return 4;
    }
    return 0;
  }

  void _handleTap(BuildContext context, int index) {
    final authState = context.read<AuthBloc>().state;
    String homeRoute = RoutePaths.login;
    if (authState is AuthAuthenticated) {
      homeRoute = AppRole.homePathFor(authState.role);
    }

    if (index == 4) {
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold != null && scaffold.hasDrawer) {
        scaffold.openDrawer();
      }
      return;
    }

    if (index == 0) {
      context.go(homeRoute);
      return;
    }

    switch (index) {
      case 0:
        context.go(homeRoute);
        break;
      case 1:
        if (authState is AuthAuthenticated) {
          switch (authState.role) {
            case 'farmer':
              context.go(RoutePaths.farmerProducts);
              break;
            case 'transport_provider':
              context.go(RoutePaths.myTrips);
              break;
            default:
              context.go(RoutePaths.productCatalog);
              break;
          }
        }
        break;
      case 2:
        if (authState is AuthAuthenticated) {
          switch (authState.role) {
            case 'farmer':
              context.go(RoutePaths.farmerOrderRequests);
              break;
            case 'transport_provider':
              context.go(RoutePaths.availableOrders);
              break;
            default:
              context.go(RoutePaths.orderHistory);
              break;
          }
        }
        break;
      case 3:
        if (authState is AuthAuthenticated) {
          switch (authState.role) {
            case 'farmer':
              context.go(RoutePaths.farmerEarnings);
              break;
            case 'transport_provider':
              context.go(RoutePaths.transportEarnings);
              break;
            default:
              context.go(RoutePaths.wishlist);
              break;
          }
        }
        break;
      case 4:
        context.go(RoutePaths.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeInfo = GoRouter.of(context).routeInformationProvider.value;
    final location = routeInfo.uri.toString();

    final authState = context.read<AuthBloc>().state;
    final currentRole = authState is AuthAuthenticated
        ? AppRole.parseUserRole(authState.role)
        : UserRole.buyer;

    return MambonamisBottomNav(
      currentIndex: _selectedIndex(location),
      onTap: (index) => _handleTap(context, index),
      role: currentRole,
    );
  }
}
