import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/earnings_widgets.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  Future<void> _refresh() async {
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Earnings',
        showNotificationAction: true,
        showBackButton: true,
        fallbackRoute: RoutePaths.farmerDashboard,
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const LoadingIndicator(message: 'Loading farm earnings');
          }

          if (state is FarmerSubOrdersLoaded) {
            final subOrders = state.subOrders;
            if (subOrders.isEmpty) {
              return EmptyState(
                title: 'No earnings yet',
                description:
                    'Your farm has not received any orders yet. Start by adding products and fulfilling order requests.',
                buttonText: 'Refresh',
                onButtonPressed: _refresh,
              );
            }

            final totalRevenue =
                subOrders.fold<double>(0.0, (sum, order) => sum + order.subtotal);
            final currentWeekRevenue =
                _calculateRevenue(subOrders, _isInCurrentWeek);
            final currentMonthRevenue =
                _calculateRevenue(subOrders, _isInCurrentMonth);
            final currentWeekOrders = _countOrders(subOrders, _isInCurrentWeek);
            final currentMonthOrders =
                _countOrders(subOrders, _isInCurrentMonth);
            final confirmedCount = subOrders.where((o) => o.isConfirmed).length;
            final confirmedRevenue =
                _calculateRevenue(subOrders, (o) => o.isConfirmed);
            final readyCount = subOrders.where((o) => o.isReady).length;
            final readyRevenue = _calculateRevenue(subOrders, (o) => o.isReady);
            final pendingCount = subOrders.where((o) => o.isPending).length;
            final pendingRevenue =
                _calculateRevenue(subOrders, (o) => o.isPending);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: AppScreen(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EarningsHero(
                      label: 'Farm earnings',
                      amount: 'Ksh ${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.agriculture_outlined,
                      stats: [
                        DashboardStat(
                          label: 'Confirmed',
                          value: confirmedCount.toString(),
                          icon: Icons.verified_outlined,
                        ),
                        DashboardStat(
                          label: 'Ready',
                          value: readyCount.toString(),
                          icon: Icons.inventory_2_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    EarningsBreakdownCard(
                      title: 'Breakdown',
                      rows: [
                        EarningsBreakdownRow(
                          label: 'This Week',
                          count: '$currentWeekOrders order(s)',
                          amount: 'Ksh ${currentWeekRevenue.toStringAsFixed(2)}',
                          icon: Icons.date_range_outlined,
                        ),
                        EarningsBreakdownRow(
                          label: 'This Month',
                          count: '$currentMonthOrders order(s)',
                          amount: 'Ksh ${currentMonthRevenue.toStringAsFixed(2)}',
                          icon: Icons.calendar_month_outlined,
                        ),
                        EarningsBreakdownRow(
                          label: 'Confirmed Orders',
                          count: '$confirmedCount order(s)',
                          amount: 'Ksh ${confirmedRevenue.toStringAsFixed(2)}',
                          icon: Icons.verified_outlined,
                        ),
                        EarningsBreakdownRow(
                          label: 'Ready Orders',
                          count: '$readyCount order(s)',
                          amount: 'Ksh ${readyRevenue.toStringAsFixed(2)}',
                          icon: Icons.inventory_2_outlined,
                        ),
                        EarningsBreakdownRow(
                          label: 'Pending Orders',
                          count: '$pendingCount order(s)',
                          amount: 'Ksh ${pendingRevenue.toStringAsFixed(2)}',
                          icon: Icons.pending_actions_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Recent order requests',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...subOrders.take(5).map(
                          (subOrder) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Order #${subOrder.id}'),
                              subtitle: Text(
                                  '${subOrder.items.length} item(s) • Ksh ${subOrder.subtotal.toStringAsFixed(2)}'),
                              trailing: Text(
                                subOrder.status.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            );
          }

          if (state is OrderError) {
            return AppErrorWidget(message: state.message);
          }

          return const Center(child: Text('Unable to load earnings.'));
        },
      ),
    );
  }

  double _calculateRevenue(List<SubOrder> orders, bool Function(SubOrder) predicate) {
    return orders.where(predicate).fold<double>(0.0, (sum, order) => sum + order.subtotal);
  }

  int _countOrders(List<SubOrder> orders, bool Function(SubOrder) predicate) {
    return orders.where(predicate).length;
  }

  bool _isInCurrentWeek(SubOrder order) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final date = order.confirmedAt ?? order.readyAt;
    if (date == null) return false;
    return !date.isBefore(DateTime(monday.year, monday.month, monday.day)) && !date.isAfter(DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59));
  }

  bool _isInCurrentMonth(SubOrder order) {
    final now = DateTime.now();
    final date = order.confirmedAt ?? order.readyAt;
    if (date == null) return false;
    return date.year == now.year && date.month == now.month;
  }
}
