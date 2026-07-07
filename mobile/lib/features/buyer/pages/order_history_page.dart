// mobile/lib/features/buyer/pages/order_history_page.dart
// mobile/lib/features/buyer/pages/order_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/themes/app_colors.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchMyOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order History',
        showBackButton: true,
        fallbackRoute: RoutePaths.buyerDashboard,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return AppErrorWidget(
              message: state.message,
              buttonText: 'Retry',
              onRetry: () => context.read<OrderBloc>().add(FetchMyOrdersEvent()),
            );
          }
          if (state is MyOrdersLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => context.read<OrderBloc>().add(FetchMyOrdersEvent()),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: EmptyState(
                          title: 'No orders yet',
                          description: 'Orders you place from the market will appear here for tracking and history.',
                          icon: Icons.receipt_long_outlined,
                          buttonText: 'Browse products',
                          onButtonPressed: () => context.go(RoutePaths.products),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<OrderBloc>().add(FetchMyOrdersEvent()),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final date = DateFormat('MMM d, yyyy • hh:mm a').format(order.createdAt.toLocal());
    final isDelivered = order.status.toLowerCase() == 'delivered';
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final statusColor = _statusColor(context, order.status);

    return CustomCard(
      onTap: () => context.push(RoutePaths.orderTrackingPath(order.uuid)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildStatusChip(context, order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              order.deliveryAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.subOrders.length} seller(s)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.totalWeightKg.toStringAsFixed(2)} kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ksh ${order.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isDelivered)
                      TextButton(
                        onPressed: () {
                          // TODO: Implement reorder logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reorder feature coming soon')),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Reorder',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final display = status.replaceAll('_', ' ').toUpperCase();
    final color = _statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        display,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Theme.of(context).colorScheme.primary;
      case 'paid_escrow':
      case 'confirmed':
        return Theme.of(context).colorScheme.secondary;
      case 'pending':
      case 'processing':
        return Theme.of(context).colorScheme.primary.withOpacity(0.9);
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}