// mobile/lib/features/buyer/pages/order_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../blocs/notification/notification_bloc.dart';
import '../../../blocs/order_tracking/order_tracking_bloc.dart';

import '../../../data/repositories/order_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_card.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderUuid;
  const OrderTrackingPage({super.key, required this.orderUuid});

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    return BlocProvider(
      create: (_) => OrderTrackingBloc(orderRepository: getIt<OrderRepository>())..add(FetchOrderTracking(orderUuid)),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Order Tracking',
            showNotificationAction: true,
            showBackButton: true,
            actions: const [CartActionButton()],
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<NotificationBloc, NotificationState>(
                listener: (context, notifState) {
                  if (notifState is NotificationLoaded) {
                    final matches = notifState.notifications.where((n) {
                      final m = n.metadata;
                      return m['order_uuid'] == orderUuid || m['order'] == orderUuid;
                    }).toList();
                    if (matches.isNotEmpty) {
                      context.read<OrderTrackingBloc>().add(NotificationAffectsOrder(matches.first));
                    }
                  }
                },
              ),
            ],
            child: BlocBuilder<OrderTrackingBloc, OrderTrackingState>(
              builder: (context, state) {
                if (state is OrderTrackingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OrderTrackingError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is OrderTrackingLoaded) {
                  final order = state.order;
                  return RefreshIndicator(
                    onRefresh: () async => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                      children: [
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${order.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              _statusBadge(context, order.status),
                              const SizedBox(height: 16),
                              Text('Delivery address', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(order.deliveryAddress, style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 16),
                              _detailRow(context, 'Created', DateFormat('MMM d, yyyy • hh:mm a').format(order.createdAt.toLocal())),
                              const SizedBox(height: 12),
                              _detailRow(context, 'Weight', '${order.totalWeightKg.toStringAsFixed(2)} kg'),
                              if (order.assignedProviderName != null) ...[
                                const SizedBox(height: 12),
                                _detailRow(context, 'Provider', order.assignedProviderName!),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              ...order.subOrders.expand((subOrder) => subOrder.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: Text(item.productName, style: Theme.of(context).textTheme.bodyLarge)),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('Qty ${item.quantity.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
                                            const SizedBox(height: 4),
                                            Text('Ksh ${item.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suborders', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              ...order.subOrders.map((subOrder) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(subOrder.farmerName, style: Theme.of(context).textTheme.bodyLarge)),
                                        _statusBadge(context, subOrder.status),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          label: 'Refresh order',
                          onPressed: () => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
        Flexible(child: Text(value, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final color = _statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
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
