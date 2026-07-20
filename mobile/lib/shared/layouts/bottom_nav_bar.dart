// lib/shared/layouts/bottom_nav_bar.dart
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../../config/role_routes.dart';

class MambonamisBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  const MambonamisBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  List<BottomNavigationBarItem> _itemsForRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Earnings'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.buyer:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Market'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Wishlist'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.transport:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Trips'),
          const BottomNavigationBarItem(icon: Icon(Icons.navigation_rounded), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.retailer:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.store_rounded), label: 'Suppliers'),
          const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.admin:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Users'),
          const BottomNavigationBarItem(icon: Icon(Icons.assessment_rounded), label: 'Reports'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        elevation: 8,
        items: _itemsForRole(role),
      );
}
