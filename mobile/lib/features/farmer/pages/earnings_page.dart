// lib/features/farmer/pages/earnings_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/earnings_summary.dart';

class FarmerEarningsPage extends StatefulWidget {
  const FarmerEarningsPage({super.key});

  @override
  State<FarmerEarningsPage> createState() => _FarmerEarningsPageState();
}

class _FarmerEarningsPageState extends State<FarmerEarningsPage> {
  // Period selection for chart
  String _selectedPeriod = 'This Week';

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
      backgroundColor: AppColors.background,
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const LoadingIndicator(message: 'Loading farm earnings');
          }

          if (state is FarmerSubOrdersLoaded) {
            final subOrders = state.subOrders;
            if (subOrders.isEmpty) {
              return _buildEmptyState();
            }

            // ── Derived data ──────────────────────────────────────────
            final totalRevenue = subOrders
                .fold<double>(0.0, (sum, order) => sum + order.subtotal);
            final totalOrders = subOrders.length;
            final confirmedOrders = subOrders.where((o) => o.status == 'confirmed').length;
            final readyOrders = subOrders.where((o) => o.status == 'ready').length;
            final pendingOrders = subOrders.where((o) => o.status == 'pending').length;

            final currentWeekRevenue = _calculateRevenue(subOrders, _isInCurrentWeek);
            final currentMonthRevenue = _calculateRevenue(subOrders, _isInCurrentMonth);
            final lastMonthRevenue = _calculateRevenue(subOrders, _isInLastMonth);

            final weekData = _computeWeeklyRevenue(subOrders);
            final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

            // ── Recent payouts (use delivered orders as payouts) ──────
            final recentPayouts = subOrders
                .where((o) => o.status == 'delivered' || o.status == 'completed')
                .take(5)
                .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: Column(
                children: [
                  // ─── Gradient Header ──────────────────────────────
                  _buildHeader(totalRevenue),

                  // ─── Scrollable body ──────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Earnings Summary ──────────────────────
                          EarningsSummary(
                            totalRevenue: totalRevenue,
                            totalOrders: totalOrders,
                            confirmedOrders: confirmedOrders,
                            readyOrders: readyOrders,
                            pendingOrders: pendingOrders,
                          ),
                          const SizedBox(height: 20),

                          // ─── Weekly Chart ──────────────────────────
                          CustomCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Weekly Earnings',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '▲ ${_calculateChange(subOrders)}%',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 120,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, _) {
                                                final index = value.toInt();
                                                if (index >= 0 && index < dayLabels.length) {
                                                  return Text(
                                                    dayLabels[index],
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.muted,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: weekData
                                                .asMap()
                                                .entries
                                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                                .toList(),
                                            isCurved: true,
                                            color: AppColors.primary,
                                            barWidth: 2.5,
                                            dotData: const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppColors.primary.withValues(alpha: 0.08),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Period selector (simple chip row)
                                  _buildPeriodChips(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ─── Month-to-Month Comparison ────────────
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'This Month',
                                  value: 'KES ${currentMonthRevenue.toStringAsFixed(0)}',
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: 'Last Month',
                                  value: 'KES ${lastMonthRevenue.toStringAsFixed(0)}',
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ─── Recent Payouts ────────────────────────
                          const SectionHeader(title: 'Recent Payouts'),
                          if (recentPayouts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No payouts yet',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ),
                            )
                          else
                            ...recentPayouts.map((order) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CustomCard(
                                    child: ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.light,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.payments_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        'KES ${order.subtotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _formatOrderDate(order),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Order #${order.id}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      onTap: () {
                                        // Navigate to order detail
                                        context.go(
                                          RoutePaths.farmerOrderRequestDetailPath(order.id),
                                          extra: order,
                                        );
                                      },
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is OrderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _refresh,
            );
          }

          return const Center(child: Text('Unable to load earnings.'));
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  // ─── Header Widget ──────────────────────────────────────────────
  Widget _buildHeader(double totalRevenue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(gradient: AppGradients.hero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.farmerDashboard);
                  }
                },
              ),
              const Text(
                'Earnings & Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'KES ${totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Withdraw flow
                        },
                        child: const Text(
                          'Withdraw',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: History flow
                        },
                        child: const Text(
                          'History',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            decoration: BoxDecoration(gradient: AppGradients.hero),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go(RoutePaths.farmerDashboard);
                        }
                      },
                    ),
                    const Text(
                      'Earnings & Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        'KES 0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: EmptyState(
              title: 'No earnings yet',
              description:
                  'Your farm has not received any orders yet. Start by adding products and fulfilling order requests.',
              buttonText: 'Refresh',
              onButtonPressed: _refresh,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Period Chips ────────────────────────────────────────────────
  Widget _buildPeriodChips() {
    final periods = ['This Week', 'This Month', 'Last Month'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: periods.map((period) {
        final selected = period == _selectedPeriod;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedPeriod = period);
            // In a real app, you'd refetch data based on the period
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.light,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Utility methods ──────────────────────────────────────────────
  double _calculateRevenue(List<SubOrder> orders, bool Function(SubOrder) predicate) {
    return orders.where(predicate).fold<double>(0.0, (sum, order) => sum + order.subtotal);
  }

  bool _isInCurrentWeek(SubOrder order) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final date = order.confirmedAt ?? order.createdAt;
    if (date == null) return false;
    return !date.isBefore(DateTime(monday.year, monday.month, monday.day)) &&
        !date.isAfter(DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59));
  }

  bool _isInCurrentMonth(SubOrder order) {
    final now = DateTime.now();
    final date = order.confirmedAt ?? order.createdAt;
    if (date == null) return false;
    return date.year == now.year && date.month == now.month;
  }

  bool _isInLastMonth(SubOrder order) {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
    final date = order.confirmedAt ?? order.createdAt;
    if (date == null) return false;
    return date.year == lastMonthYear && date.month == lastMonth;
  }

  List<double> _computeWeeklyRevenue(List<SubOrder> orders) {
    final weekData = List.filled(7, 0.0);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    for (final order in orders) {
      final date = order.confirmedAt ?? order.createdAt;
      if (date == null) continue;
      final diff = date.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        weekData[diff] += order.subtotal;
      }
    }
    return weekData;
  }

  String _formatOrderDate(SubOrder order) {
    final date = order.confirmedAt ?? order.createdAt;
    if (date == null) return 'Unknown date';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String _calculateChange(List<SubOrder> orders) {
    final thisMonth = _calculateRevenue(orders, _isInCurrentMonth);
    final lastMonth = _calculateRevenue(orders, _isInLastMonth);
    if (lastMonth == 0) return '0';
    final change = ((thisMonth - lastMonth) / lastMonth * 100);
    return change.abs().toStringAsFixed(1);
  }
}

// ─── Helper widget ──────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}