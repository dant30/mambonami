// mobile/lib/shared/layouts/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../config/role_routes.dart';
import '../../config/route_paths.dart';
import '../themes/app_colors.dart';
import '../themes/app_gradients.dart';
import '../utils/form_validators.dart';
import '../widgets/avatar.dart';

// ── Internal menu item definition ─────────────────────────────
class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final List<String> allowedRoles; // empty = everyone

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    this.allowedRoles = const [],
  });
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    // ── Extract user info ──────────────────────────────────────
    String phone = '';
    String role = '';
    String username = '';
    String? avatarUrl;
    String? displayNameValue;
    if (authState is AuthAuthenticated) {
      phone = authState.phone;
      role = authState.role;
      username = authState.username ?? '';
      avatarUrl = authState.avatarUrl;
      displayNameValue = authState.displayName;
    }

    final formattedPhone =
        phone.isNotEmpty ? FormValidators.formatPhone(phone) : '';
    final displayName = (displayNameValue ?? username).trim().isNotEmpty
        ? (displayNameValue ?? username)
        : (formattedPhone.isNotEmpty ? formattedPhone : 'Guest');
    final displayPhone =
        formattedPhone.isNotEmpty ? formattedPhone : 'Not signed in';
    final roleLabel = AppRole.displayLabel(role);
    final homeRoute = AppRole.homePathFor(role);

    // ── Current location for active highlighting ──────────────
    final routeInfo = GoRouter.of(context).routeInformationProvider.value;
    final currentLocation = routeInfo.uri.toString();

    bool isRouteSelected(String route) {
      final normalizedLocation = currentLocation.split('?').first;
      return normalizedLocation == route ||
          normalizedLocation.startsWith('$route/');
    }

    // ── Badge counts ──────────────────────────────────────────
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

    // ── Menu definitions ──────────────────────────────────────
    final primaryItems = <_DrawerItem>[
      _DrawerItem(
        icon: Icons.home_rounded,
        title: 'Home',
        route: homeRoute,
        allowedRoles: [],
      ),
      const _DrawerItem(
        icon: Icons.shopping_bag_rounded,
        title: 'Products',
        route: RoutePaths.products,
        allowedRoles: AppRole.buyerRoles,
      ),
      const _DrawerItem(
        icon: Icons.shopping_cart_rounded,
        title: 'Cart',
        route: RoutePaths.cart,
        allowedRoles: AppRole.buyerRoles,
      ),
      const _DrawerItem(
        icon: Icons.receipt_long_rounded,
        title: 'My Orders',
        route: RoutePaths.orders,
        allowedRoles: AppRole.buyerRoles,
      ),
      const _DrawerItem(
        icon: Icons.inventory_2_rounded,
        title: 'My Products',
        route: RoutePaths.farmerProducts,
        allowedRoles: AppRole.farmerRoles,
      ),
      const _DrawerItem(
        icon: Icons.list_alt_rounded,
        title: 'Order Requests',
        route: RoutePaths.farmerOrderRequests,
        allowedRoles: AppRole.farmerRoles,
      ),
      const _DrawerItem(
        icon: Icons.show_chart_rounded,
        title: 'Earnings',
        route: RoutePaths.farmerEarnings,
        allowedRoles: AppRole.farmerRoles,
      ),
      const _DrawerItem(
        icon: Icons.local_shipping_rounded,
        title: 'Available Orders',
        route: RoutePaths.availableOrders,
        allowedRoles: AppRole.transportProviderRoles,
      ),
      const _DrawerItem(
        icon: Icons.route_rounded,
        title: 'My Trips',
        route: RoutePaths.myTrips,
        allowedRoles: AppRole.transportProviderRoles,
      ),
      const _DrawerItem(
        icon: Icons.payments_rounded,
        title: 'Earnings',
        route: RoutePaths.transportEarnings,
        allowedRoles: AppRole.transportProviderRoles,
      ),
      const _DrawerItem(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        route: RoutePaths.notifications,
        allowedRoles: [],
      ),
    ];

    final roleSpecificItems = <_DrawerItem>[
      if (role == AppRole.farmer) ...[
        const _DrawerItem(
          icon: Icons.agriculture_rounded,
          title: 'Cooperative Yield Register',
          route: RoutePaths.farmerProducts,
          allowedRoles: AppRole.farmerRoles,
        ),
        const _DrawerItem(
          icon: Icons.inventory_2_rounded,
          title: 'Harvest & Inventory',
          route: RoutePaths.farmerProducts,
          allowedRoles: AppRole.farmerRoles,
        ),
        const _DrawerItem(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Pickup Queue',
          route: RoutePaths.farmerOrderRequests,
          allowedRoles: AppRole.farmerRoles,
        ),
      ] else if (role == AppRole.transportProvider) ...[
        const _DrawerItem(
          icon: Icons.local_shipping_rounded,
          title: 'Available Load Trips',
          route: RoutePaths.availableOrders,
          allowedRoles: AppRole.transportProviderRoles,
        ),
        const _DrawerItem(
          icon: Icons.route_rounded,
          title: 'Route Dispatch',
          route: RoutePaths.myTrips,
          allowedRoles: AppRole.transportProviderRoles,
        ),
        const _DrawerItem(
          icon: Icons.file_present_rounded,
          title: 'Trip Documents',
          route: RoutePaths.transportEarnings,
          allowedRoles: AppRole.transportProviderRoles,
        ),
      ] else if (role == AppRole.buyer || role == AppRole.retailer) ...[
        const _DrawerItem(
          icon: Icons.favorite_outline_rounded,
          title: 'Favourite Farmers',
          route: RoutePaths.products,
          allowedRoles: AppRole.buyerRoles,
        ),
        const _DrawerItem(
          icon: Icons.inventory_2_rounded,
          title: 'Bulk Orders',
          route: RoutePaths.orders,
          allowedRoles: AppRole.buyerRoles,
        ),
        const _DrawerItem(
          icon: Icons.local_shipping_rounded,
          title: 'Delivery Tracking',
          route: RoutePaths.orders,
          allowedRoles: AppRole.buyerRoles,
        ),
      ],
    ];

    final secondaryItems = <_DrawerItem>[
      const _DrawerItem(
        icon: Icons.person_outline_rounded,
        title: 'Profile',
        route: RoutePaths.profile,
        allowedRoles: [],
      ),
      const _DrawerItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        route: RoutePaths.settings,
        allowedRoles: [],
      ),
      const _DrawerItem(
        icon: Icons.help_outline_rounded,
        title: 'Support',
        route: RoutePaths.support,
        allowedRoles: [],
      ),
    ];

    // ── Helper to build a badge ──────────────────────────────
    Widget buildTrailingBadge(int count) {
      if (count <= 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
            // ── Header ───────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(
                    imageUrl: avatarUrl,
                    username: displayName,
                    firstName: displayName.split(' ').firstWhere(
                        (value) => value.isNotEmpty,
                        orElse: () => ''),
                    lastName: displayName.split(' ').length > 1
                        ? displayName.split(' ').lastWhere(
                            (value) => value.isNotEmpty,
                            orElse: () => '')
                        : null,
                    size: 64,
                    showBorder: false,
                    backgroundColor: Colors.white24,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayPhone,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      roleLabel.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Menu list ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Primary items
                  ...primaryItems
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
                          .withValues(alpha: 0.08),
                      iconColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      textColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: selected
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    );
                  }),

                  if (roleSpecificItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        'Role tools',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                      ),
                    ),
                    ...roleSpecificItems
                        .where((item) =>
                            item.allowedRoles.isEmpty ||
                            item.allowedRoles.contains(role))
                        .map((item) {
                      final bool selected = isRouteSelected(item.route);
                      return ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                        selected: selected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        iconColor: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        textColor: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: selected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        dense: true,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.route);
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                  ],

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Legal & Trust',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms of Service'),
                    dense: true,
                    onTap: () => showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Terms of Service'),
                        content: const Text(
                          'By using Mambonami, you agree to use the platform responsibly, keep your account information accurate, and follow local agricultural and logistics regulations.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    dense: true,
                    onTap: () => showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Privacy Policy'),
                        content: const Text(
                          'We use your profile and delivery details to provide a safer marketplace experience, process payments, and improve service reliability.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 24, indent: 8, endIndent: 8),

                  // Secondary items
                  ...secondaryItems
                      .where((item) =>
                          item.allowedRoles.isEmpty ||
                          item.allowedRoles.contains(role))
                      .map((item) {
                    final bool selected = isRouteSelected(item.route);
                    return ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      selected: selected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      iconColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      textColor: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: selected
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    );
                  }),

                  const Divider(height: 16, indent: 8, endIndent: 8),

                  // Logout item
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(LogoutEvent());
                      context.go(RoutePaths.login);
                    },
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'MAMBONAMI v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
