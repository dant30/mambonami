// mobile/lib/features/buyer/pages/order_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../blocs/notification/notification_bloc.dart';
import '../../../blocs/order_tracking/order_tracking_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/rating_stars.dart';

class OrderTrackingPage extends StatelessWidget {
  final String orderUuid;
  const OrderTrackingPage({super.key, required this.orderUuid});

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => OrderTrackingBloc(orderRepository: getIt<OrderRepository>())
        ..add(FetchOrderTracking(orderUuid)),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Order Tracking',
            showBackButton: true,
            fallbackRoute: RoutePaths.buyerDashboard,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
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
                      context.read<OrderTrackingBloc>().add(
                        NotificationAffectsOrder(matches.first),
                      );
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 12),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is OrderTrackingLoaded) {
                  final order = state.order;
                  final isDelivered = order.status.toLowerCase() == 'delivered';

                  return RefreshIndicator(
                    onRefresh: () async => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 16 + MediaQuery.of(context).padding.bottom),
                      children: [
                        // ─── Gradient Header ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          decoration: BoxDecoration(
                            gradient: isDark ? AppGradients.cool : AppGradients.hero,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Order #${order.id}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDelivered ? 'Delivered ✓' : order.status.replaceAll('_', ' ').toUpperCase(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Status chip
                              _statusBadge(context, order.status, light: true),
                            ],
                          ),
                        ),

                        // ─── Map Preview ─────────────────────────────────
                        CustomCard(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  color: AppColors.lightGreen.withOpacity(0.3),
                                  child: Stack(
                                    children: [
                                      // Map image placeholder (use Google Maps in production)
                                      Image.network(
                                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&h=160&fit=crop&auto=format',
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 140,
                                          color: AppColors.lightGreen.withOpacity(0.3),
                                          child: const Center(
                                            child: Icon(
                                              Icons.map_outlined,
                                              size: 48,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.route_outlined,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                order.totalDistanceKm != null
                                                    ? '${order.totalDistanceKm!.toStringAsFixed(1)} km'
                                                    : '— km',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.dark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Driver info row
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.lightGreen,
                                      child: order.providerPhotoUrl != null
                                          ? ClipOval(
                                              child: Image.network(
                                                order.providerPhotoUrl!,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(Icons.person, color: AppColors.primary),
                                              ),
                                            )
                                          : const Icon(Icons.person, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.assignedProviderName ?? 'Transport Provider',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            order.providerVehicle ?? 'Vehicle assigned',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: order.providerPhone != null
                                          ? () => _callProvider(order.providerPhone!)
                                          : null,
                                      icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                                      tooltip: 'Call provider',
                                    ),
                                  ],
                                ),
                              ),
                              // Stats row
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    _StatItem(
                                      label: 'Distance',
                                      value: order.totalDistanceKm != null
                                          ? '${order.totalDistanceKm!.toStringAsFixed(1)} km'
                                          : '—',
                                      icon: Icons.route_outlined,
                                    ),
                                    _StatItem(
                                      label: 'ETA',
                                      value: order.etaMinutes != null
                                          ? '${order.etaMinutes} min'
                                          : '—',
                                      icon: Icons.access_time_outlined,
                                    ),
                                    _StatItem(
                                      label: 'Rating',
                                      value: order.providerRating != null
                                          ? order.providerRating!.toStringAsFixed(1)
                                          : '—',
                                      icon: Icons.star_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── Order Details Card ──────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Details',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _detailRow(
                                    context,
                                    'Delivery address',
                                    order.deliveryAddress,
                                  ),
                                  const SizedBox(height: 8),
                                  _detailRow(
                                    context,
                                    'Created',
                                    DateFormat('MMM d, yyyy • hh:mm a')
                                        .format(order.createdAt.toLocal()),
                                  ),
                                  const SizedBox(height: 8),
                                  _detailRow(
                                    context,
                                    'Weight',
                                    '${order.totalWeightKg.toStringAsFixed(2)} kg',
                                  ),
                                  if (order.paybillNumber != null &&
                                      order.paybillNumber!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _detailRow(
                                      context,
                                      'Paybill',
                                      order.paybillNumber!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ─── Timeline ────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: CustomCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Timeline',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._buildTimeline(context, order),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ─── Refresh Button ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomButton(
                            label: 'Refresh order',
                            onPressed: () => context.read<OrderTrackingBloc>().add(RefreshOrderTracking()),
                            outlined: true,
                          ),
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

  void _callProvider(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<Widget> _buildTimeline(BuildContext context, dynamic order) {
    final theme = Theme.of(context);
    // Define timeline steps based on order status
    final steps = [
      'Order Placed',
      'Payment Received',
      'Farmer Accepted',
      'Order Ready',
      'Transport Assigned',
      'On the Way',
      'Delivered',
    ];

    // Determine which steps are completed
    // Map order status to completed step index
    final statusMap = {
      'placed': 0,
      'paid_escrow': 1,
      'farmer_confirmed': 2,
      'farmer_ready': 3,
      'transport_assigned': 4,
      'picked_up': 5,
      'delivered': 6,
    };
    final currentStep = statusMap[order.status.toLowerCase()] ?? 0;

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final isCompleted = index <= currentStep;
      final isActive = index == currentStep && !order.isDelivered;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? (isActive ? AppColors.gold : theme.colorScheme.primary)
                        : theme.colorScheme.outline.withOpacity(0.3),
                    border: Border.all(
                      color: isCompleted
                          ? (isActive ? AppColors.gold : theme.colorScheme.primary)
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          isActive ? Icons.local_shipping_outlined : Icons.check,
                          color: Colors.white,
                          size: isActive ? 18 : 14,
                        )
                      : null,
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isCompleted
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'LIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isCompleted && index < steps.length - 1)
                    Text(
                      _getStepDescription(index),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getStepDescription(int index) {
    switch (index) {
      case 0:
        return 'Order received and recorded';
      case 1:
        return 'Funds secured in escrow';
      case 2:
        return 'Farmer confirmed your order';
      case 3:
        return 'Produce packed and ready for pickup';
      case 4:
        return 'Provider assigned to deliver';
      case 5:
        return 'On the way to you';
      default:
        return '';
    }
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, String status, {bool light = false}) {
    final color = _statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: light ? Colors.white.withOpacity(0.2) : color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: light ? Colors.white : color,
          fontWeight: FontWeight.w700,
        ),
      ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}