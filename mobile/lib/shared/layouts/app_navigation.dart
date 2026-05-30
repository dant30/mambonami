import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../config/route_paths.dart';
import 'bottom_nav_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  int _selectedIndex(String location) {
    if (location.startsWith(RoutePaths.buyerDashboard) || location.startsWith(RoutePaths.farmerDashboard) || location.startsWith(RoutePaths.transportProviderDashboard)) {
      return 0;
    }
    if (location.startsWith(RoutePaths.notifications)) return 1;
    if (location.startsWith(RoutePaths.support)) return 2;
    if (location.startsWith(RoutePaths.profile)) return 3;
    return 0;
  }

  void _handleTap(BuildContext context, int index) {
    final authState = context.read<AuthBloc>().state;
    String homeRoute = RoutePaths.login;
    if (authState is AuthAuthenticated) {
      if (authState.role == 'buyer') homeRoute = RoutePaths.buyerDashboard;
      if (authState.role == 'farmer') homeRoute = RoutePaths.farmerDashboard;
      if (authState.role == 'transport_provider') homeRoute = RoutePaths.transportProviderDashboard;
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
    return BottomNavBar(
      currentIndex: _selectedIndex(location),
      onTap: (index) => _handleTap(context, index),
      items: const [
        BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
        BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notifications'),
        BottomNavItem(icon: Icons.support_agent_outlined, activeIcon: Icons.support_agent, label: 'Support'),
        BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
      ],
    );
  }
}
