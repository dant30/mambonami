import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/custom_app_bar.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Trigger load of user's orders
    context.read<OrderBloc>().add(FetchMyOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Orders',
        showNotificationAction: true,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) return const Center(child: CircularProgressIndicator());
          if (state is OrderError) return Center(child: Text('Error: ${state.message}'));
          if (state is MyOrdersLoaded) {
            final List<Order> orders = state.orders;
            if (orders.isEmpty) return const Center(child: Text('No orders yet'));
            return RefreshIndicator(
              onRefresh: () async => context.read<OrderBloc>().add(FetchMyOrdersEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, idx) {
                  final o = orders[idx];
                  return ListTile(
                    title: Text(o.uuid),
                    subtitle: Text('${o.status} • ${o.createdAt.toLocal().toString().split('.').first}'),
                    trailing: Text(o.totalAmount.toStringAsFixed(2)),
                    onTap: () => context.go('/order/${o.uuid}'),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
// mobile/lib/features/buyer/pages/order_history_page.dart