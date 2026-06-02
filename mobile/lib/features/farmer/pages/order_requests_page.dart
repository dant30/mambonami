import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/order_request_card.dart';
import '../../../data/models/order.dart';

class OrderRequestsPage extends StatefulWidget {
  const OrderRequestsPage({super.key});

  @override
  State<OrderRequestsPage> createState() => _OrderRequestsPageState();
}

class _OrderRequestsPageState extends State<OrderRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  Future<void> _refresh() async {
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  void _openDetail(SubOrder subOrder) {
    context.go(RoutePaths.farmerOrderRequestDetailPath(subOrder.id), extra: subOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Order Requests', showNotificationAction: true),
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
                title: 'No order requests',
                description: 'You have not received any farm orders yet. Check back after your products are listed.',
                buttonText: 'Refresh list',
                onButtonPressed: _refresh,
              );
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.78)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Confirm and fulfill incoming farm orders', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final subOrder = subOrders[index];
                        return OrderRequestCard(subOrder: subOrder, onTap: () => _openDetail(subOrder));
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemCount: subOrders.length,
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is OrderError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Unable to load order requests.'));
        },
      ),
    );
  }
}
