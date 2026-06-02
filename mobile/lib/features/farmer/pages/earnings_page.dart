import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';

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
            return const LoadingIndicator();
          }

          if (state is FarmerSubOrdersLoaded) {
            final subOrders = state.subOrders;
            if (subOrders.isEmpty) {
              return EmptyState(
                title: 'No earnings yet',
                description: 'Your farm has not received any orders yet. Start by adding products and fulfilling order requests.',
                buttonText: 'Refresh',
                onButtonPressed: _refresh,
              );
            }

            final totalRevenue = subOrders.fold<double>(0.0, (sum, order) => sum + order.subtotal);
            final currentWeekRevenue = _calculateRevenue(subOrders, _isInCurrentWeek);
            final currentMonthRevenue = _calculateRevenue(subOrders, _isInCurrentMonth);
            final currentWeekOrders = _countOrders(subOrders, _isInCurrentWeek);
            final currentMonthOrders = _countOrders(subOrders, _isInCurrentMonth);
            final confirmedCount = subOrders.where((o) => o.isConfirmed).length;
            final readyCount = subOrders.where((o) => o.isReady).length;
            final pendingCount = subOrders.where((o) => o.isPending).length;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.withValues(alpha: 0.1),
                            Colors.green.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Earnings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              'Ksh ${totalRevenue.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildEarningsStat('Confirmed', confirmedCount.toString(), context),
                                Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
                                _buildEarningsStat('Ready', readyCount.toString(), context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildPeriodRow('This Week', currentWeekOrders, currentWeekRevenue, context),
                          Divider(color: Colors.grey.withValues(alpha: 0.2)),
                          _buildPeriodRow('This Month', currentMonthOrders, currentMonthRevenue, context),
                          Divider(color: Colors.grey.withValues(alpha: 0.2)),
                          _buildBreakdownRow('Confirmed Orders', confirmedCount.toString(), 'Ksh ${totalRevenue.toStringAsFixed(2)}', context),
                          Divider(color: Colors.grey.withValues(alpha: 0.2)),
                          _buildBreakdownRow('Ready Orders', readyCount.toString(), 'Ksh 0', context),
                          Divider(color: Colors.grey.withValues(alpha: 0.2)),
                          _buildBreakdownRow('Pending Orders', pendingCount.toString(), 'Ksh 0', context),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent order requests', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...subOrders.take(5).map(
                        (subOrder) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text('Order #${subOrder.id}'),
                            subtitle: Text('${subOrder.items.length} item(s) • Ksh ${subOrder.subtotal.toStringAsFixed(2)}'),
                            trailing: Text(subOrder.status.toUpperCase()),
                          ),
                        ),
                      ),
                ],
              ),
            );
          }

          if (state is OrderError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Unable to load earnings.'));
        },
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String count, String amount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(count, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          Text(amount, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(String label, int count, double amount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('$count orders', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          Text('Ksh ${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
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
