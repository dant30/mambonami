// // mobile/lib/shared/layouts/app_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
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
    if (normalizedLocation == RoutePaths.notifications ||
        normalizedLocation.startsWith('${RoutePaths.notifications}/')) return 1;
    if (normalizedLocation == RoutePaths.support ||
        normalizedLocation.startsWith('${RoutePaths.support}/')) return 2;
    if (normalizedLocation == RoutePaths.profile ||
        normalizedLocation.startsWith('${RoutePaths.profile}/')) return 3;
    return 0;
  }

  void _handleTap(BuildContext context, int index) {
    final authState = context.read<AuthBloc>().state;
    String homeRoute = RoutePaths.login;
    if (authState is AuthAuthenticated) {
      homeRoute = AppRole.homePathFor(authState.role);
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
        context.go(RoutePaths.notifications);
        break;
      case 2:
        context.go(RoutePaths.support);
        break;
      case 3:
        context.go(RoutePaths.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeInfo = GoRouter.of(context).routeInformationProvider.value;
    final location = routeInfo.uri.toString();

    // Watch notification state to get unread count
    final notifState = context.watch<NotificationBloc>().state;
    int unreadNotifications = 0;
    if (notifState is NotificationLoaded) {
      unreadNotifications =
          notifState.notifications.where((n) => n.isUnread).length;
    }

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
