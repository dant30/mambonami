import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/order/order_bloc.dart';

class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final List<String> allowedRoles; // empty = everyone

  const _DrawerItem({required this.icon, required this.title, required this.route, this.allowedRoles = const []});
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
    if (authState is AuthAuthenticated) {
      phone = authState.phone;
      role = authState.role;
    }

    final homeRoute = authState is AuthAuthenticated ? '/${authState.role}' : '/login';
    bool isRouteSelected(String route) => currentLocation == route || currentLocation.startsWith(route);

    // Badge counts (computed at build time)
    final notifState = context.watch<NotificationBloc>().state;
    int unreadNotifications = 0;
    if (notifState is NotificationLoaded) {
      unreadNotifications = notifState.notifications.where((n) => n.isUnread).length;
    }

    final orderState = context.watch<OrderBloc>().state;
    int ordersCount = 0;
    if (orderState is MyOrdersLoaded) {
      ordersCount = orderState.orders.length;
    }

    // Data-driven menu
    final primary = <_DrawerItem>[
      _DrawerItem(icon: Icons.home, title: 'Home', route: homeRoute, allowedRoles: []),
      _DrawerItem(icon: Icons.list_alt, title: 'My Orders', route: '/orders', allowedRoles: ['buyer', 'retailer']),
      _DrawerItem(icon: Icons.notifications, title: 'Notifications', route: '/notifications', allowedRoles: []),
    ];

    final secondary = <_DrawerItem>[
      _DrawerItem(icon: Icons.person, title: 'Profile', route: '/profile'),
      _DrawerItem(icon: Icons.settings, title: 'Settings', route: '/settings'),
      _DrawerItem(icon: Icons.support_agent, title: 'Support', route: '/support'),
    ];

    Widget buildTrailingBadge(int count) {
      if (count <= 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(role.isNotEmpty ? role.toUpperCase() : 'Guest'),
              accountEmail: Text(phone.isNotEmpty ? phone : 'Not signed in'),
              currentAccountPicture: CircleAvatar(child: Text((role.isNotEmpty ? role[0] : 'G').toUpperCase())),
            ),
            // Primary
            ...primary.where((item) => item.allowedRoles.isEmpty || item.allowedRoles.contains(role)).map((item) {
              final bool selected = isRouteSelected(item.route);
              int badge = 0;
              if (item.route == '/notifications') badge = unreadNotifications;
              if (item.route == '/orders') badge = ordersCount;
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                trailing: badge > 0 ? buildTrailingBadge(badge) : null,
                selected: selected,
                selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.route);
                },
              );
            }),
            const Divider(),
            // Secondary
            ...secondary.where((item) => item.allowedRoles.isEmpty || item.allowedRoles.contains(role)).map((item) {
              final bool selected = isRouteSelected(item.route);
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                selected: selected,
                selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
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
