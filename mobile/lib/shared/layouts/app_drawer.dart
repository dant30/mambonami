// mobile/lib/shared/layouts/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../config/role_routes.dart';
import '../../config/route_paths.dart';
import '../themes/app_gradients.dart';
import '../themes/app_shadows.dart';
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
    final roleLabel = AppRole.displayLabel(role);
    final homeRoute = AppRole.homePathFor(role);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          route: RoutePaths.products,
          allowedRoles: AppRole.buyerRoles),
      _DrawerItem(
          icon: Icons.shopping_cart,
          title: 'Cart',
          route: RoutePaths.cart,
          allowedRoles: AppRole.buyerRoles),
      _DrawerItem(
          icon: Icons.receipt_long,
          title: 'My Orders',
          route: RoutePaths.orders,
          allowedRoles: AppRole.buyerRoles),
      _DrawerItem(
          icon: Icons.inventory,
          title: 'My Products',
          route: RoutePaths.farmerProducts,
          allowedRoles: AppRole.farmerRoles),
      _DrawerItem(
          icon: Icons.list_alt,
          title: 'Order Requests',
          route: RoutePaths.farmerOrderRequests,
          allowedRoles: AppRole.farmerRoles),
      _DrawerItem(
          icon: Icons.show_chart,
          title: 'Earnings',
          route: RoutePaths.farmerEarnings,
          allowedRoles: AppRole.farmerRoles),
      _DrawerItem(
          icon: Icons.local_shipping,
          title: 'Available Orders',
          route: RoutePaths.availableOrders,
          allowedRoles: AppRole.transportProviderRoles),
      _DrawerItem(
          icon: Icons.route,
          title: 'My Trips',
          route: RoutePaths.myTrips,
          allowedRoles: AppRole.transportProviderRoles),
      _DrawerItem(
          icon: Icons.payments,
          title: 'Earnings',
          route: RoutePaths.transportEarnings,
          allowedRoles: AppRole.transportProviderRoles),
      _DrawerItem(
          icon: Icons.notifications,
          title: 'Notifications',
          route: RoutePaths.notifications,
          allowedRoles: []),
    ];

    final secondary = <_DrawerItem>[
      _DrawerItem(
          icon: Icons.person, title: 'Profile', route: RoutePaths.profile),
      _DrawerItem(
          icon: Icons.settings, title: 'Settings', route: RoutePaths.settings),
      _DrawerItem(
          icon: Icons.support_agent,
          title: 'Support',
          route: RoutePaths.support),
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
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      );
    }

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.hero,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppShadows.glow,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.44),
                              width: 1.4,
                            ),
                          ),
                          child: Avatar(
                            username: username.isNotEmpty ? username : phone,
                            size: 64,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayPhone,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              PillBadge(
                                label: roleLabel,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.18),
                                foregroundColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white.withValues(alpha: 0.88),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'MAMBONAMI',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Primary
                  ...primary
                      .where((item) =>
                          item.allowedRoles.isEmpty ||
                          item.allowedRoles.contains(role))
                      .map((item) {
                    final bool selected = isRouteSelected(item.route);
                    int badge = 0;
                    if (item.route == RoutePaths.notifications) {
                      badge = unreadNotifications;
                    }
                    if (item.route == RoutePaths.orders) {
                      badge = ordersCount;
                    }
                    return ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      trailing: badge > 0 ? buildTrailingBadge(badge) : null,
                      selected: selected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      iconColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: isDark ? 0.82 : 0.72),
                      textColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      dense: true,
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
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    );
                  }),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log out'),
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(LogoutEvent());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
