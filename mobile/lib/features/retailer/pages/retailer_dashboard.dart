// lib/features/retailer/pages/retailer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/custom_button.dart';

class RetailerDashboard extends StatelessWidget {
  const RetailerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final orderState = context.watch<OrderBloc>().state;
    String username = '';
    String? avatarUrl;
    if (authState is AuthAuthenticated) {
      username = authState.displayName ?? authState.username ?? authState.phone;
      avatarUrl = authState.avatarUrl;
    }
    final activeOrders = orderState is MyOrdersLoaded
        ? orderState.orders
            .where((o) => o.status != 'delivered' && o.status != 'cancelled')
            .length
        : 0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Retailer Dashboard',
        showNotificationAction: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4C1D95).withValues(alpha: 0.05),
              AppColors.background
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, username, avatarUrl),
              const SizedBox(height: 16),
              _buildPurchaseChart(context),
              const SizedBox(height: 16),
              _buildStats(context, activeOrders),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Quick Reorder',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('All items'),
                ),
              ),
              const SizedBox(height: 8),
              _buildReorderList(context),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Active Orders',
                trailing: TextButton(
                  onPressed: () => context.go(RoutePaths.orders),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 8),
              _buildActiveOrders(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _buildHeader(
      BuildContext context, String username, String? avatarUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.go(RoutePaths.profile),
              child: Avatar(
                imageUrl: avatarUrl,
                username: username.isNotEmpty ? username : 'Retailer',
                firstName:
                    username.isNotEmpty ? username.split(' ').first : null,
                lastName: username.split(' ').length > 1
                    ? username.split(' ').last
                    : null,
                size: 48,
                showBorder: false,
                backgroundColor:
                    AppColors.transportPurple.withValues(alpha: 0.15),
                textStyle: const TextStyle(
                    color: AppColors.transportPurple,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Retailer Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    username.isNotEmpty ? username : 'Kamau Fresh Groceries',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseChart(BuildContext context) {
    final data = [
      ['W1', 48000],
      ['W2', 72000],
      ['W3', 61000],
      ['W4', 89000],
    ];

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monthly Purchases',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Text('▲ 8.1%',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          return Text('${data[val.toInt()][0]}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textMuted));
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value[1] as double,
                          color: AppColors.transportPurple,
                          width: 28,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, int activeOrders) {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: AppColors.transportPurple),
                  const SizedBox(height: 4),
                  Text('$activeOrders',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const Text('Active Orders',
                      style:
                          TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: CustomCard(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(Icons.store_outlined, color: AppColors.secondaryGreen),
                  SizedBox(height: 4),
                  Text('24',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('Suppliers',
                      style:
                          TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReorderList(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'name': 'Avocado',
        'supplier': 'Kamau Farm',
        'qty': '50 kg',
        'price': 'KES 12,500',
        'img':
            'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=50&h=50&fit=crop'
      },
      {
        'name': 'Tomatoes',
        'supplier': 'Wanjiku Farm',
        'qty': '100 kg',
        'price': 'KES 9,000',
        'img':
            'https://images.unsplash.com/photo-1546470427-e26264be0b07?w=50&h=50&fit=crop'
      },
      {
        'name': 'Sukuma Wiki',
        'supplier': 'Thika Farms',
        'qty': '200 bunches',
        'price': 'KES 4,000',
        'img':
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=50&h=50&fit=crop'
      },
    ];

    return Column(
      children: items.map((item) {
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.md,
                  child: Image.network(item['img'] as String,
                      width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${item['supplier']} · ${item['qty']}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      Text(item['price'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
                CustomButton(
                  label: 'Reorder',
                  onPressed: () {},
                  fullWidth: false,
                  minWidth: 80,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveOrders(BuildContext context) {
    final orders = <Map<String, dynamic>>[
      {
        'id': 'ORD-4821',
        'farmer': 'Kamau Farm',
        'item': 'Avocado 50kg',
        'amount': 'KES 12,500',
        'status': 'Picked Up',
        'color': AppColors.secondaryGreen
      },
      {
        'id': 'ORD-4819',
        'farmer': 'Wanjiku Farm',
        'item': 'Tomatoes 100kg',
        'amount': 'KES 9,000',
        'status': 'Farmer Ready',
        'color': AppColors.warning
      },
    ];

    return Column(
      children: orders.map((order) {
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order['id']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (order['color'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius: AppRadius.sm,
                            ),
                            child: Text(order['status']!,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: order['color'] as Color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${order['farmer']} · ${order['item']}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(order['amount']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
