// mobile/lib/features/transport/pages/available_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/trip.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';

class AvailableOrdersPage extends StatefulWidget {
  const AvailableOrdersPage({super.key});

  @override
  State<AvailableOrdersPage> createState() => _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(FetchAvailableOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(8, 52, 20, 20),
            decoration: const BoxDecoration(gradient: AppGradients.hero),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () =>
                      context.go(RoutePaths.transportProviderDashboard),
                ),
                const Expanded(
                  child: Text('Available Deliveries',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                  onPressed: () {
                    // Future: filter/sort options
                  },
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<TripBloc, TripState>(
              listener: (context, state) {
                if (state is TripError) {
                  CustomSnackbar.showError(context, state.message);
                }
                if (state is TripAssigned) {
                  CustomSnackbar.showSuccess(
                      context, 'Order accepted! Head to pickup.');
                  // Navigate to trip detail after assignment
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      context.push(RoutePaths.tripDetailPath(state.trip.uuid));
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is TripLoading) {
                  return const LoadingIndicator(message: 'Loading available orders...');
                }

                if (state is AvailableOrdersLoaded) {
                  final orders = state.orders;
                  if (orders.isEmpty) {
                    return EmptyState(
                      title: 'No available orders',
                      message:
                          'New delivery work will appear here when farms mark orders ready for transport.',
                      icon: Icons.local_shipping_outlined,
                      buttonText: 'Refresh',
                      onButtonPressed: () {
                        context.read<TripBloc>().add(FetchAvailableOrdersEvent());
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<TripBloc>().add(FetchAvailableOrdersEvent());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Summary stats strip ──────────────────────
                          _AvailableOrdersSummary(orders: orders),
                          const SizedBox(height: 16),

                          // ── Offer cards ──────────────────────────────
                          ...orders.map(
                            (trip) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderOfferCard(
                                trip: trip,
                                onAccept: () {
                                  context
                                      .read<TripBloc>()
                                      .add(AssignOrderEvent(trip.order));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is TripError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<TripBloc>().add(FetchAvailableOrdersEvent());
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary stats strip ──────────────────────────────────────────────

class _AvailableOrdersSummary extends StatelessWidget {
  final List<Trip> orders;

  const _AvailableOrdersSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalOffers = orders.length;
    final estimatedFees = orders.fold<double>(
      0,
      (sum, trip) => sum + (trip.agreedFee ?? 0),
    );
    final geoReady = orders
        .where((trip) =>
            trip.pickupLat != null &&
            trip.pickupLng != null &&
            trip.deliveryLat != null &&
            trip.deliveryLng != null)
        .length;

    return DashboardStatStrip(
      stats: [
        DashboardStat(
          label: 'Offers',
          value: totalOffers.toString(),
          icon: Icons.local_shipping_outlined,
        ),
        DashboardStat(
          label: 'Est. fees',
          value: 'Ksh ${estimatedFees.toStringAsFixed(0)}',
          icon: Icons.payments_outlined,
        ),
        DashboardStat(
          label: 'Mapped',
          value: geoReady.toString(),
          icon: Icons.map_outlined,
        ),
      ],
    );
  }
}

// ── Individual order offer card ──────────────────────────────────────

class OrderOfferCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onAccept;

  const OrderOfferCard({
    super.key,
    required this.trip,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderId = trip.order.toString();
    final fee = trip.agreedFee ?? 0.0;
    final distance = trip.distanceKm ?? 0.0;
    final eta = trip.etaMinutes ?? 0;
    final pickup = trip.pickupLat != null && trip.pickupLng != null
        ? 'Farm location'
        : 'Pickup location';
    final delivery = trip.deliveryLat != null && trip.deliveryLng != null
        ? 'Delivery location'
        : 'Delivery location';

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order ID & fee ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#$orderId',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'KES ${fee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Route: pickup → delivery ───────────────────────────
            Row(
              children: [
                // Dots and line
                Column(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.success),
                    Container(width: 1, height: 20, color: AppColors.light),
                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.error),
                  ],
                ),
                const SizedBox(width: 10),
                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        delivery,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Distance & ETA
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '~$eta min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Accept button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAccept,
                child: const Text(
                  'Accept Delivery',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}