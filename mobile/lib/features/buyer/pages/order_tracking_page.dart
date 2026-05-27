import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../blocs/order_tracking/order_tracking_bloc.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../blocs/notification/notification_bloc.dart';

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
					appBar: AppBar(title: const Text('Order Tracking')),
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
								if (state is OrderTrackingLoading) return const Center(child: CircularProgressIndicator());
								if (state is OrderTrackingError) return Center(child: Text('Error: ${state.message}'));
								if (state is OrderTrackingLoaded) {
									final order = state.order;
									return RefreshIndicator(
										onRefresh: () async => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
										child: ListView(
											padding: const EdgeInsets.all(16),
											children: [
												Text('Order: ${order.uuid}', style: Theme.of(context).textTheme.titleLarge),
												const SizedBox(height: 12),
												Text('Status: ${order.status}', style: Theme.of(context).textTheme.bodyLarge),
												const SizedBox(height: 12),
												if (order.assignedProviderName != null) ...[
													Text('Provider: ${order.assignedProviderName}'),
													const SizedBox(height: 12),
												],
												const Divider(),
												Text('Items', style: Theme.of(context).textTheme.titleMedium),
												const SizedBox(height: 8),
												...order.subOrders.expand((s) => s.items.map((i) => ListTile(
															title: Text(i.productName),
															subtitle: Text('Qty: ${i.quantity}'),
															trailing: Text('${i.totalPrice.toStringAsFixed(2)}'),
														))),
												const Divider(),
												Text('Suborders', style: Theme.of(context).textTheme.titleMedium),
												...order.subOrders.map((s) => ListTile(
															title: Text(s.farmerName),
															subtitle: Text('Status: ${s.status}'),
															trailing: s.readyAt != null ? const Icon(Icons.check_circle, color: Colors.green) : null,
														)),
												const SizedBox(height: 20),
												ElevatedButton.icon(
													onPressed: () => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
													icon: const Icon(Icons.refresh),
													label: const Text('Refresh'),
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
}