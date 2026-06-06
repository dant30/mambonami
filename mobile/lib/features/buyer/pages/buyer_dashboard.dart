import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buyer Dashboard',
        showNotificationAction: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [CartActionButton()],
      ),
      drawer: const AppDrawer(),
      body: AppScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoleHeroCard(
              title: username.isNotEmpty
                  ? 'Fresh picks, $username'
                  : 'Fresh picks',
              subtitle:
                  'Browse verified produce, checkout fast, and follow every delivery from market to doorstep.',
              icon: Icons.shopping_basket_outlined,
              gradient: AppGradients.cool,
              actions: [
                HeroActionButton(
                  label: 'Browse',
                  icon: Icons.search_rounded,
                  onTap: () => context.push(RoutePaths.products),
                ),
                HeroActionButton(
                  label: 'Cart',
                  icon: Icons.shopping_cart_checkout_rounded,
                  onTap: () => context.push(RoutePaths.cart),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DashboardStatStrip(
              stats: [
                DashboardStat(
                  label: 'Orders',
                  value: 'Live',
                  icon: Icons.receipt_long_outlined,
                ),
                DashboardStat(
                  label: 'Produce',
                  value: 'Fresh',
                  icon: Icons.eco_outlined,
                ),
                DashboardStat(
                  label: 'Support',
                  value: 'Ready',
                  icon: Icons.support_agent_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
              children: [
                DashboardActionTile(
                  icon: Icons.storefront_outlined,
                  title: 'Browse Products',
                  subtitle: 'Fresh verified goods',
                  accentColor: AppColors.buyerAccent,
                  onTap: () => context.push(RoutePaths.products),
                ),
                DashboardActionTile(
                  icon: Icons.receipt_long,
                  title: 'My Orders',
                  subtitle: 'Track purchases',
                  accentColor: AppColors.secondaryLight,
                  onTap: () => context.push(RoutePaths.orders),
                ),
                DashboardActionTile(
                  icon: Icons.support_agent,
                  title: 'Support',
                  subtitle: 'Get help quickly',
                  accentColor: AppColors.farmerAccent,
                  onTap: () => context.push(RoutePaths.support),
                ),
                DashboardActionTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  subtitle: 'Latest updates',
                  accentColor: Colors.purple,
                  onTap: () => context.push(RoutePaths.notifications),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
