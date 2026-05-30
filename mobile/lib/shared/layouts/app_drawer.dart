import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../widgets/avatar.dart';
import '../widgets/pill_badge.dart';

class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final List<String> allowedRoles; // empty = everyone

  const _DrawerItem(
      {required this.icon,
      required this.title,
      required this.route,
      this.allowedRoles = const []});
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final routeInfo = GoRouter.of(context).routeInformationProvider.value;
    final currentLocation = routeInfo.uri.toString();

    String phone = '';
    String role = '';
    String username = '';
    if (authState is AuthAuthenticated) {
      phone = authState.phone;
      role = authState.role;
      username = authState.username ?? '';
    }

    final displayName =
        username.isNotEmpty ? username : (phone.isNotEmpty ? phone : 'Guest');
    final displayPhone = phone.isNotEmpty ? phone : 'Not signed in';
    final roleLabel = role.isNotEmpty ? role : 'Guest';
    final homeRoute =
        authState is AuthAuthenticated ? '/${authState.role}' : '/login';
    bool isRouteSelected(String route) =>
        currentLocation == route || currentLocation.startsWith(route);

    // Badge counts (computed at build time)
    final notifState = context.watch<NotificationBloc>().state;
    int unreadNotifications = 0;
    if (notifState is NotificationLoaded) {
      unreadNotifications =
          notifState.notifications.where((n) => n.isUnread).length;
    }

    final orderState = context.watch<OrderBloc>().state;
    int ordersCount = 0;
    if (orderState is MyOrdersLoaded) {
      ordersCount = orderState.orders.length;
    }

    // Data-driven menu
    final primary = <_DrawerItem>[
      _DrawerItem(
          icon: Icons.home, title: 'Home', route: homeRoute, allowedRoles: []),
      _DrawerItem(
          icon: Icons.shopping_bag,
          title: 'Products',
          route: '/products',
          allowedRoles: ['buyer', 'retailer']),
        _DrawerItem(
          icon: Icons.inventory,
          title: 'My Products',
          route: '/farmer/products',
          allowedRoles: ['farmer']),
      _DrawerItem(
          icon: Icons.list_alt,
          title: 'My Orders',
          route: '/orders',
          allowedRoles: ['buyer', 'retailer']),
      _DrawerItem(
          icon: Icons.notifications,
          title: 'Notifications',
          route: '/notifications',
          allowedRoles: []),
    ];

    final secondary = <_DrawerItem>[
      _DrawerItem(icon: Icons.person, title: 'Profile', route: '/profile'),
      _DrawerItem(icon: Icons.settings, title: 'Settings', route: '/settings'),
      _DrawerItem(
          icon: Icons.support_agent, title: 'Support', route: '/support'),
    ];

    Widget buildTrailingBadge(int count) {
      if (count <= 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12)),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2),
                    ),
                    child: Avatar(
                      username: username.isNotEmpty ? username : phone,
                      size: 80,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayPhone,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        PillBadge(label: roleLabel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Primary
            ...primary
                .where((item) =>
                    item.allowedRoles.isEmpty ||
                    item.allowedRoles.contains(role))
                .map((item) {
              final bool selected = isRouteSelected(item.route);
              int badge = 0;
              if (item.route == '/notifications') badge = unreadNotifications;
              if (item.route == '/orders') badge = ordersCount;
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                trailing: badge > 0 ? buildTrailingBadge(badge) : null,
                selected: selected,
                selectedTileColor:
                    Theme.of(context).colorScheme.primary.withAlpha(30),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.route);
                },
              );
            }),
            const Divider(),
            // Secondary
            ...secondary
                .where((item) =>
                    item.allowedRoles.isEmpty ||
                    item.allowedRoles.contains(role))
                .map((item) {
              final bool selected = isRouteSelected(item.route);
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: selected,
                selectedTileColor:
                    Theme.of(context).colorScheme.primary.withAlpha(30),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.route);
                },
              );
            }),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
