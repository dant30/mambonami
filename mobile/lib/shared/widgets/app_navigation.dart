import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import 'bottom_nav_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  int _selectedIndex(String location) {
    if (location.startsWith('/notifications')) return 1;
    if (location.startsWith('/support')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _handleTap(BuildContext context, int index) {
    final authState = context.read<AuthBloc>().state;
    final homeRoute = authState is AuthAuthenticated ? '/${authState.role}' : '/login';

    switch (index) {
      case 0:
        context.go(homeRoute);
        break;
      case 1:
        context.go('/notifications');
        break;
      case 2:
        context.go('/support');
        break;
      case 3:
        context.go('/profile');
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
