// mobile/lib/features/farmer/pages/order_requests_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';

class OrderRequestsPage extends StatefulWidget {
  const OrderRequestsPage({super.key});

  @override
  State<OrderRequestsPage> createState() => _OrderRequestsPageState();
}

class _OrderRequestsPageState extends State<OrderRequestsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabLabels = ['New', 'Confirmed', 'Ready', 'All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  void _openDetail(SubOrder subOrder) {
    context.go(
      RoutePaths.farmerOrderRequestDetailPath(subOrder.id),
      extra: subOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Order Requests',
        showBackButton: true,
        showNotificationAction: true,
        fallbackRoute: RoutePaths.farmerDashboard,
      ),
      drawer: const AppDrawer(),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            CustomSnackbar.showError(context, state.message);
          }
          if (state is SubOrderConfirmed || state is SubOrderDeclined) {
            CustomSnackbar.showSuccess(context, 'Order updated successfully!');
            _refresh(); // reload list after action
          }
        },
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const LoadingIndicator();
          }

          if (state is FarmerSubOrdersLoaded) {
            final subOrders = state.subOrders;
            if (subOrders.isEmpty) {
              return EmptyState(
                title: 'No order requests',
                description:
                    'You have not received any farm orders yet. Check back after your products are listed.',
                icon: Icons.assignment_turned_in_outlined,
                buttonText: 'Refresh',
                onButtonPressed: _refresh,
              );
            }

            // Filter orders per tab
            final newOrders = subOrders.where((o) => o.status == 'pending').toList();
            final confirmedOrders = subOrders.where((o) => o.status == 'confirmed').toList();
            final readyOrders = subOrders.where((o) => o.status == 'ready').toList();
            final allOrders = subOrders;

            // Counts for summary chips
            final pendingCount = newOrders.length;
            final confirmedCount = confirmedOrders.length;
            final readyCount = readyOrders.length;

            return Column(
              children: [
                // ── Summary chips ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppGradients.hero,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incoming requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confirm, prep, and fulfill orders without missing your pickup window.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SummaryChip(label: '$pendingCount pending', color: AppColors.warning),
                          _SummaryChip(label: '$confirmedCount confirmed', color: AppColors.secondary),
                          _SummaryChip(label: '$readyCount ready', color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Tab bar ──────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
                ),

                // ── Tab views ───────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _OrderList(orders: newOrders, onTap: _openDetail),
                        _OrderList(orders: confirmedOrders, onTap: _openDetail),
                        _OrderList(orders: readyOrders, onTap: _openDetail),
                        _OrderList(orders: allOrders, onTap: _openDetail),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unable to load order requests.'));
        },
      ),
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Order list (used per tab) ────────────────────────────────────────────────
class _OrderList extends StatelessWidget {
  final List<SubOrder> orders;
  final void Function(SubOrder) onTap;

  const _OrderList({required this.orders, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.muted, size: 48),
            const SizedBox(height: 12),
            Text(
              'No orders in this category',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = orders[i];

        // Determine status color
        final statusColor = o.isPending
            ? AppColors.warning
            : o.status == 'confirmed'
                ? AppColors.secondary
                : AppColors.primary;

        return CustomCard(
          onTap: () => onTap(o),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID, buyer, time, status badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${o.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${o.farmerName} · ${o.confirmedAt != null ? 'Confirmed' : 'Just now'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      o.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Order summary
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      o.items.map((item) => '${item.productName} × ${item.quantity}').join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'KES ${o.subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Action buttons for pending orders
              if (o.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          context.read<OrderBloc>().add(
                                ConfirmSubOrderEvent(o.id),
                              );
                        },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: () {
                        context.read<OrderBloc>().add(
                              DeclineSubOrderEvent(o.id),
                            );
                      },
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}