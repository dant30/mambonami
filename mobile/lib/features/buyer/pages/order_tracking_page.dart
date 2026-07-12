// lib/features/buyer/pages/order_tracking_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/delivery_tracking_card.dart';
import '../widgets/order_status_timeline.dart';

class OrderTrackingPage extends StatefulWidget {
  final String? orderId;
  final String? orderUuid;
  const OrderTrackingPage({super.key, this.orderId, this.orderUuid});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  void initState() {
    super.initState();
    final orderId = widget.orderId ?? widget.orderUuid;
    if (orderId != null) {
      context
          .read<OrderBloc>()
          .add(FetchOrderDetailsEvent(orderId: orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────
            Container(
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Order Tracking',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        final label = state is OrderDetailLoaded
                            ? state.order.statusLabel
                            : '—';
                        final orderId = widget.orderId ?? widget.orderUuid ?? 'unknown';
                        return Text(
                          'Order #${orderId.substring(0, 8).toUpperCase()} · $label',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (state is OrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<OrderBloc>().add(
                                FetchOrderDetailsEvent(
                                    orderId: widget.orderId ?? widget.orderUuid ?? '')),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => context
                        .read<OrderBloc>()
                        .add(FetchOrderDetailsEvent(
                            orderId: widget.orderId ?? widget.orderUuid ?? '')),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        children: [
                          // Map + driver card
                          DeliveryTrackingCard(
                            driverName: 'David Ochieng',
                            vehicleLabel: 'Motorcycle · KAB 123A',
                            distanceKm: 1.2,
                            etaMinutes: 8,
                            rating: 4.8,
                            driverImageUrl:
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop',
                            mapImageUrl:
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=380&h=140&fit=crop',
                            onCallDriver: () {},
                          ),
                          const SizedBox(height: 16),

                          // 7-step timeline
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Timeline',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                const OrderStatusTimeline(
                                  events: [
                                    OrderStatusEvent(
                                      title: 'Order Placed',
                                      description:
                                          'Order received and recorded',
                                      timestamp: '10:32 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Payment Received',
                                      description:
                                          'Funds secured in escrow',
                                      timestamp: '10:33 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Farmer Accepted',
                                      description:
                                          'John Kamau confirmed your order',
                                      timestamp: '10:45 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Order Ready',
                                      description:
                                          'Produce packed for pickup',
                                      timestamp: '11:20 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Transport Assigned',
                                      description: 'David O. accepted trip',
                                      timestamp: '11:35 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'On the Way',
                                      description:
                                          '1.2 km away · ETA 8 minutes',
                                      timestamp: '11:52 AM',
                                      isCompleted: true,
                                      isActive: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Delivered',
                                      description:
                                          'Awaiting delivery confirmation',
                                      timestamp: '—',
                                      isCompleted: false,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}