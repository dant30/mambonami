// mobile/lib/features/transport/pages/my_trips_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../widgets/trip_card.dart'; // assumes you have a TripCard widget

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  @override
  void initState() {
    super.initState();
    _refreshTrips();
  }

  void _refreshTrips() {
    context.read<TripBloc>().add(FetchMyTripsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(8, 52, 20, 20),
            decoration: BoxDecoration(gradient: AppGradients.hero),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () =>
                      context.go(RoutePaths.transportProviderDashboard),
                ),
                const Text('My Trips',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<TripBloc, TripState>(
              builder: (context, state) {
                if (state is TripLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }

                if (state is MyTripsLoaded) {
                  final trips = state.trips;
                  if (trips.isEmpty) {
                    return Center(
                      child: EmptyState(
                        title: 'No trips yet',
                        message: 'Accepted deliveries will appear here.',
                        buttonText: 'Refresh',
                        onButtonPressed: _refreshTrips,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshTrips(),
                    child: AppScreen(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Summary stats ──────────────────────────
                          _TripsSummary(trips: trips),
                          const SizedBox(height: 16),

                          // ── Trip list ──────────────────────────────
                          ...trips.map(
                            (trip) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TripCard(
                                trip: trip,
                                onTap: () {
                                  context.push(
                                      RoutePaths.tripDetailPath(trip.uuid));
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshTrips,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
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

// ── Summary stats widget ────────────────────────────────────────────
class _TripsSummary extends StatelessWidget {
  final List trips;

  const _TripsSummary({required this.trips});

  @override
  Widget build(BuildContext context) {
    final completed = trips.where((t) => t.status.toLowerCase() == 'delivered').length;
    final active = trips.where((t) => ['accepted','assigned','picked_up','en_route_pickup','en_route_delivery','arrived_pickup','arrived_delivery','otp_pending'].contains(t.status.toLowerCase())).length;
    final totalEarned = trips
        .where((t) => t.status.toLowerCase() == 'delivered')
        .fold<double>(0, (sum, t) => sum + (t.agreedFee ?? 0));

    return DashboardStatStrip(
      stats: [
        DashboardStat(
          label: 'Active',
          value: active.toString(),
          icon: Icons.route_outlined,
        ),
        DashboardStat(
          label: 'Completed',
          value: completed.toString(),
          icon: Icons.verified_outlined,
        ),
        DashboardStat(
          label: 'Earned',
          value: 'KES ${totalEarned.toStringAsFixed(0)}',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}