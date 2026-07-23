// mobile/lib/features/transport/pages/provider_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart' as order_bloc;
import '../../../blocs/trip/trip_bloc.dart' as trip_bloc;
import '../../../config/route_paths.dart';
import '../../../data/models/payout_summary.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/payout_repository.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/active_trip_banner.dart';
import '../widgets/offline_banner.dart';
import '../widgets/map_preview.dart';
import '../widgets/hero_card.dart';
import '../widgets/delivery_request_card.dart';
import '../widgets/earnings_strip.dart';
import '../widgets/quick_actions.dart';
import '../widgets/stats_section.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  bool _isOnline = true;
  PayoutSummary? _payoutSummary;
  String? _payoutError;

  @override
  void initState() {
    super.initState();
    context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchMyTripsEvent());
    context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchAvailableOrdersEvent());
    _loadPayoutSummary();
  }

  Future<void> _loadPayoutSummary() async {
    try {
      final payoutSummary = await GetIt.instance<PayoutRepository>().getTransportPayoutSummary();
      if (!mounted) return;
      setState(() {
        _payoutSummary = payoutSummary;
        _payoutError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _payoutError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final tripState = context.watch<trip_bloc.TripBloc>().state;
    final orderState = context.watch<order_bloc.OrderBloc>().state;

    String username = '';
    String? avatarUrl;
    String? vehicleType;
    String? licensePlate;
    double rating = 5.0;
    int completedDeliveries = 0;

    if (authState is AuthAuthenticated) {
      username = authState.displayName ?? authState.username ?? authState.phone;
      avatarUrl = authState.avatarUrl;
      vehicleType = authState.vehicleType;
      licensePlate = authState.licensePlate;
      rating = authState.providerRating ?? 5.0;
      completedDeliveries = authState.completedDeliveries ?? 0;
    }

    final trips = tripState is trip_bloc.MyTripsLoaded ? tripState.trips : <Trip>[];
    final availableOrders = tripState is trip_bloc.AvailableOrdersLoaded ? tripState.orders : <Trip>[];
    final activeTrip = _findActiveTrip(trips);
    final activeTrips = _activeTripsCount(trips);
    final completedTrips = trips.where((trip) => trip.completedAt != null).length;
    final pendingTrips = trips.where((trip) => trip.completedAt == null && trip.status.toLowerCase() != 'cancelled').length;
    final earnings = trips.fold<double>(
      0.0,
      (sum, trip) => sum + (trip.agreedFee ?? 0.0) + (trip.waitingSurcharge ?? 0.0),
    );
    final todayEarnings = trips
        .where((trip) =>
            trip.createdAt.isAfter(
              DateTime.now().subtract(const Duration(days: 1)),
            ))
        .fold<double>(0.0, (sum, trip) => sum + (trip.agreedFee ?? 0.0) + (trip.waitingSurcharge ?? 0.0));

    final payoutSummary = _payoutSummary;
    final summaryToday = payoutSummary?.todayPayoutAmount ?? todayEarnings;
    final summaryCompletedCount = payoutSummary?.completedPayoutCount ?? completedTrips;
    final summaryPendingPayout = payoutSummary?.pendingPayoutAmount ?? (pendingTrips > 0 ? earnings * 0.65 : 0.0);
    final summaryTotalRevenue = payoutSummary?.totalPayoutAmount ?? earnings;
    final summaryErrorText = _payoutError;

    final statusLabel = activeTrips > 0
        ? 'On a delivery'
        : (_isOnline ? 'Online — accepting orders' : 'Offline — unavailable');

    final greetingSubtitle = activeTrip != null
        ? 'Deliver safely. Your customer is waiting.'
        : (todayEarnings > 500
            ? 'Amazing work today! You\'ve earned KES ${todayEarnings.toStringAsFixed(0)}.'
            : 'Ready to earn today? New deliveries are available.');

    // Get order details for the active trip (if any)
    Order? activeOrder;
    if (activeTrip != null && orderState is order_bloc.OrderDetailLoaded) {
      activeOrder = orderState.order;
    }

    // Mock weather (replace with real API later)
    const weather = '☀ 27° Sunny';

    return Scaffold(
      drawer: const AppDrawer(),
      body: AppScreen(
        scrollable: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchMyTripsEvent());
            context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchAvailableOrdersEvent());
            await _loadPayoutSummary();
          },
          color: AppColors.providerAccent,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
                // ── Header ─────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GreetingHeader(
                        name: username,
                        subtitle: greetingSubtitle,
                        showDate: true,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        nameStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        subtitleStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () => context.go(RoutePaths.notifications),
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.go(RoutePaths.profile),
                      child: Avatar(
                        imageUrl: avatarUrl,
                        username: username,
                        firstName: username.split(' ').firstWhere(
                              (value) => value.isNotEmpty,
                              orElse: () => '',
                            ),
                        lastName: username.split(' ').length > 1
                            ? username.split(' ').lastWhere(
                                (value) => value.isNotEmpty,
                                orElse: () => '',
                              )
                            : null,
                        size: 44,
                        showBorder: true,
                        backgroundColor: Colors.white24,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Vehicle Card ──────────────────────────────────────
                if (vehicleType != null)
                  VehicleCard(
                    vehicleType: vehicleType,
                    licensePlate: licensePlate,
                    rating: rating,
                    completedDeliveries: completedDeliveries,
                  ),
                const SizedBox(height: 12),

                // ── Active Trip Banner ──────────────────────────────
                if (activeTrip != null)
                  ActiveTripBanner(trip: activeTrip, order: activeOrder)
                else if (!_isOnline)
                  const OfflineBanner(),
                const SizedBox(height: 12),

                // ── Live Map Preview ────────────────────────────────
                if (activeTrip != null) ...[
                  LiveMapPreview(trip: activeTrip),
                  const SizedBox(height: 12),
                ],

                // ── Hero Card ────────────────────────────────────────
                HeroCard(
                  activeTrips: activeTrips,
                  todayEarnings: summaryToday,
                  username: username,
                  isOnline: _isOnline,
                  availableOrdersCount: availableOrders.length,
                  onToggleOnline: () => setState(() => _isOnline = !_isOnline),
                  onAvailable: () => context.push(RoutePaths.availableOrders),
                  onMyTrips: () => context.push(RoutePaths.myTrips),
                  onEarnings: () => context.push(RoutePaths.transportEarnings),
                ),
                const SizedBox(height: 18),

                // ── Delivery Request Card ────────────────────────────
                if (availableOrders.isNotEmpty && activeTrip == null)
                  DeliveryRequestCard(
                    trip: availableOrders.first,
                    onAccept: () {
                      context.read<trip_bloc.TripBloc>().add(
                            trip_bloc.AssignOrderEvent(availableOrders.first.uuid),
                          );
                    },
                    onDecline: () {
                      context.read<trip_bloc.TripBloc>().add(
                            trip_bloc.FetchAvailableOrdersEvent(),
                          );
                    },
                  ),

                // ── Earnings Analytics ──────────────────────────────
                EarningsAnalyticsStrip(
                  todayEarnings: summaryToday,
                  completedTrips: summaryCompletedCount,
                  pendingPayout: summaryPendingPayout,
                  earnings: summaryTotalRevenue,
                  payoutError: summaryErrorText,
                ),
                const SizedBox(height: 18),

                // ── Quick Access ─────────────────────────────────────
                QuickActions(hasActiveTrip: activeTrip != null),
                const SizedBox(height: 18),

                // ── Stats Section ────────────────────────────────────
                StatsSection(
                  activeTrips: activeTrips,
                  earnings: earnings,
                  todayEarnings: todayEarnings,
                  statusLabel: statusLabel,
                  weather: weather,
                ),
                ],
            ),
          ),
        ),
      floatingActionButton: activeTrip != null
          ? FloatingActionButton.extended(
              onPressed: () => _openNavigation(activeTrip),
              icon: const Icon(Icons.navigation_rounded),
              label: Text(activeTrip.status.toLowerCase() == 'picked_up'
                  ? 'Navigate to Delivery'
                  : 'Navigate to Pickup'),
              backgroundColor: AppColors.providerAccent,
            )
          : null,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Trip? _findActiveTrip(List<Trip> trips) {
    for (final trip in trips) {
      final status = trip.status.toLowerCase();
      if (status != 'delivered' && status != 'cancelled') {
        return trip;
      }
    }
    return null;
  }

  int _activeTripsCount(List<Trip> trips) {
    return trips
        .where(
          (trip) =>
              trip.status.toLowerCase() != 'delivered' &&
              trip.status.toLowerCase() != 'cancelled',
        )
        .length;
  }

  Future<void> _openNavigation(Trip trip) async {
    final origin = '${trip.pickupLat},${trip.pickupLng}';
    final destination = '${trip.deliveryLat},${trip.deliveryLng}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open navigation.')),
      );
    }
  }
}