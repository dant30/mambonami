import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class OrderDetailPage extends StatelessWidget {
  final SubOrder subOrder;

  const OrderDetailPage({super.key, required this.subOrder});

  void _confirmOrder(BuildContext context) {
    context.read<OrderBloc>().add(ConfirmSubOrderEvent(subOrder.id));
  }

  void _markReady(BuildContext context) {
    context.read<OrderBloc>().add(MarkSubOrderReadyEvent(subOrder.id));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is SubOrderConfirmed && state.subOrderId == subOrder.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order confirmed.')),
          );
        }
        if (state is SubOrderReady && state.subOrderId == subOrder.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked as ready.')),
          );
        }
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is OrderLoading;
        return Scaffold(
          appBar: const CustomAppBar(title: 'Order Request Details'),
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Order #${subOrder.id}', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(subOrder.status.toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Text('Farmer: ${subOrder.farmerName}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('₦${subOrder.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 24),
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...subOrder.items.map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.productName),
                        subtitle: Text('${item.quantity.toStringAsFixed(0)} × ₦${item.unitPrice.toStringAsFixed(2)}'),
                        trailing: Text('₦${item.totalPrice.toStringAsFixed(2)}'),
                      )),
                  const SizedBox(height: 24),
                  Text('Order activity', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Confirmed at'),
                    subtitle: Text(_formatDate(subOrder.confirmedAt)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ready at'),
                    subtitle: Text(_formatDate(subOrder.readyAt)),
                  ),
                  const SizedBox(height: 24),
                  if (subOrder.isPending)
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _confirmOrder(context),
                      child: const Text('Confirm Order'),
                    ),
                  if (subOrder.isConfirmed)
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _markReady(context),
                      child: const Text('Mark Ready'),
                    ),
                  if (subOrder.isReady)
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Order Ready'),
                    ),
                ],
              ),
              if (isLoading)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}
