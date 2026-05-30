import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/earnings_summary.dart';

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
      appBar: const CustomAppBar(title: 'Earnings', showNotificationAction: true),
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
            final confirmedCount = subOrders.where((o) => o.isConfirmed).length;
            final readyCount = subOrders.where((o) => o.isReady).length;
            final pendingCount = subOrders.where((o) => o.isPending).length;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                children: [
                  EarningsSummary(
                    totalRevenue: totalRevenue,
                    totalOrders: subOrders.length,
                    confirmedOrders: confirmedCount,
                    readyOrders: readyCount,
                    pendingOrders: pendingCount,
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
}
