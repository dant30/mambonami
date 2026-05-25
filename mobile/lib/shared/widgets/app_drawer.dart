import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';

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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: isRouteSelected(homeRoute),
              selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onTap: () {
                Navigator.of(context).pop();
                context.go(homeRoute);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: isRouteSelected('/profile'),
              selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              selected: isRouteSelected('/settings'),
              selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              selected: isRouteSelected('/support'),
              selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/support');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              selected: isRouteSelected('/notifications'),
              selectedTileColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/notifications');
              },
            ),
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
