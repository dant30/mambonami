// lib/features/farmer/pages/order_requests_page.dart
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
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/order_request_card.dart';

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
            _refresh();
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
                        _buildOrderList(
                          context,
                          orders: newOrders,
                          emptyMessage: 'No new requests.\nRelax while orders come in.',
                        ),
                        _buildOrderList(
                          context,
                          orders: confirmedOrders,
                          emptyMessage: 'No confirmed orders waiting.\nAll good.',
                        ),
                        _buildOrderList(
                          context,
                          orders: readyOrders,
                          emptyMessage: 'No orders ready for pickup.',
                        ),
                        _buildOrderList(
                          context,
                          orders: allOrders,
                          emptyMessage: 'No orders at all.\nList products to get started.',
                        ),
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

  Widget _buildOrderList(BuildContext context,
      {required List<SubOrder> orders, required String emptyMessage}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.muted, size: 48),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
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
        final subOrder = orders[i];
        return OrderRequestCard(
          subOrder: subOrder,
          onConfirm: subOrder.isPending
              ? () {
                  context.read<OrderBloc>().add(ConfirmSubOrderEvent(subOrder.id));
                }
              : null,
          onDecline: subOrder.isPending
              ? () {
                  context.read<OrderBloc>().add(DeclineSubOrderEvent(subOrder.id));
                }
              : null,
          onTap: () => _openDetail(subOrder),
        );
      },
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