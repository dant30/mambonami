// mobile/lib/features/transport/pages/provider_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/greeting_header.dart';

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
    final weather = '☀ 27° Sunny';

    return Scaffold(
      drawer: const AppDrawer(),
      body: AppScreen(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchMyTripsEvent());
            context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchAvailableOrdersEvent());
            await _loadPayoutSummary();
          },
          color: AppColors.providerAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  _buildVehicleCard(
                    context,
                    vehicleType,
                    licensePlate,
                    rating,
                    completedDeliveries,
                  ),
                const SizedBox(height: 12),

                // ── Active Trip Banner (enhanced) ────────────────────
                if (activeTrip != null)
                  _buildEnhancedActiveTripBanner(context, activeTrip, activeOrder)
                else if (!_isOnline)
                  _buildOfflineBanner(context),
                const SizedBox(height: 12),

                // ── Live Map Preview ──────────────────────────────────
                if (activeTrip != null) ...[
                  _buildLiveMapPreview(context, activeTrip),
                  const SizedBox(height: 12),
                ],

                // ── Hero Card (dynamic) ──────────────────────────────
                _buildDynamicHeroCard(
                  context,
                  activeTrips: activeTrips,
                  todayEarnings: summaryToday,
                  username: username,
                  isOnline: _isOnline,
                  availableOrdersCount: availableOrders.length,
                ),
                const SizedBox(height: 18),

                // ── Delivery Request Card (first available) ──────────
                if (availableOrders.isNotEmpty && activeTrip == null)
                  _buildDeliveryRequestCard(
                    context,
                    trip: availableOrders.first,
                    onAccept: () {
                      context.read<trip_bloc.TripBloc>().add(trip_bloc.AssignOrderEvent(availableOrders.first.uuid));
                    },
                    onDecline: () {
                      context.read<trip_bloc.TripBloc>().add(trip_bloc.FetchAvailableOrdersEvent());
                    },
                  ),

                // ── Earnings Analytics ───────────────────────────────
                _buildEarningsAnalyticsStrip(
                  context,
                  todayEarnings: summaryToday,
                  completedTrips: summaryCompletedCount,
                  pendingPayout: summaryPendingPayout,
                  earnings: summaryTotalRevenue,
                  payoutError: summaryErrorText,
                ),
                const SizedBox(height: 18),

                // ── Quick Access (revamped) ──────────────────────────
                _buildQuickAccessCards(context, activeTrip != null),
                const SizedBox(height: 18),

                // ── Stats Section ─────────────────────────────────────
                _buildStatsSection(
                  context,
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
      ),
      floatingActionButton: activeTrip != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Open navigation or call customer
                _openNavigation(activeTrip);
              },
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

  // ── Helper methods ──────────────────────────────────────────────────────

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
        SnackBar(content: Text('Unable to open navigation.')),
      );
    }
  }

  // ─── Widget builders ────────────────────────────────────────────────────

  Widget _buildVehicleCard(
    BuildContext context,
    String vehicleType,
    String? licensePlate,
    double rating,
    int completedDeliveries,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (licensePlate != null && licensePlate.isNotEmpty)
                  Text(
                    licensePlate,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completedDeliveries trips',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActiveTripBanner(BuildContext context, Trip trip, Order? order) {
    final farmerName = order?.subOrders.isNotEmpty == true ? order!.subOrders.first.farmerName : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.providerAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.providerAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                color: AppColors.providerAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Trip',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.providerAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.providerAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.providerAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Farmer & produce
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  farmerName ?? 'Farmer',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_grocery_store_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order?.itemsSummary ?? 'Produce',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Customer & amount
          Row(
            children: [
              const Icon(Icons.home_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order?.buyerName ?? 'Customer',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'KES ${trip.agreedFee?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                'ETA ${trip.etaMinutes ?? '—'} min · ${trip.distanceKm?.toStringAsFixed(1) ?? '—'} km',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => context.push(RoutePaths.tripDetailPath(trip.uuid)),
                child: const Icon(Icons.arrow_forward_rounded, color: AppColors.providerAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pause_circle_outline_rounded,
            color: Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'You are Offline',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Text(
                  'Tap the toggle below to start receiving orders.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapPreview(BuildContext context, Trip trip) {
    final hasPickup = trip.pickupLat != null && trip.pickupLng != null;
    final hasDelivery = trip.deliveryLat != null && trip.deliveryLng != null;

    if (!hasPickup || !hasDelivery) {
      return const SizedBox.shrink();
    }

    final pickup = LatLng(trip.pickupLat!, trip.pickupLng!);
    final delivery = LatLng(trip.deliveryLat!, trip.deliveryLng!);
    final midpoint = LatLng(
      (pickup.latitude + delivery.latitude) / 2,
      (pickup.longitude + delivery.longitude) / 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Route Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: midpoint,
                  zoom: 11,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: pickup,
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('delivery'),
                    position: delivery,
                    infoWindow: const InfoWindow(title: 'Delivery'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeroCard(
    BuildContext context, {
    required int activeTrips,
    required double todayEarnings,
    required String username,
    required bool isOnline,
    required int availableOrdersCount,
  }) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.logistics,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.success.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOnline ? '● Online' : '● Offline',
                            style: TextStyle(
                              color: isOnline ? AppColors.success : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (availableOrdersCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$availableOrdersCount new',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Online toggle
              Row(
                children: [
                  const Icon(
                    Icons.circle_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isOnline = !_isOnline),
                    child: Container(
                      width: 48,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? AppColors.success
                            : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _isOnline ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroActionTile(
                  label: 'Available',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => context.push(RoutePaths.availableOrders),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroActionTile(
                  label: 'My Trips',
                  icon: Icons.route_outlined,
                  onTap: () => context.push(RoutePaths.myTrips),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroActionTile(
                  label: 'Earnings',
                  icon: Icons.attach_money_rounded,
                  onTap: () => context.push(RoutePaths.transportEarnings),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today_rounded, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Today: KES ${todayEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9 ★',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryRequestCard(BuildContext context, {required Trip trip, required VoidCallback onAccept, required VoidCallback onDecline}) {
    final theme = Theme.of(context);
    final pickupLabel = trip.pickupLat != null && trip.pickupLng != null ? 'Pickup point' : 'Farm';
    final deliveryLabel = trip.deliveryLat != null && trip.deliveryLng != null ? 'Delivery point' : 'Customer';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: AppColors.providerAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW DELIVERY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'KES ${trip.agreedFee?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Text('Farmer', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                pickupLabel,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Text('Customer', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                deliveryLabel,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${trip.distanceKm?.toStringAsFixed(1) ?? '—'} km · ETA ${trip.etaMinutes ?? '—'} min',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.providerAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsAnalyticsStrip(
    BuildContext context, {
    required double todayEarnings,
    required int completedTrips,
    required double pendingPayout,
    required double earnings,
    String? payoutError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings & Payouts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnalyticsTile(
                label: 'Today',
                value: 'KES ${todayEarnings.toStringAsFixed(0)}',
                icon: Icons.today_rounded,
                accentColor: AppColors.providerAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsTile(
                label: 'Completed',
                value: completedTrips.toString(),
                icon: Icons.check_circle_rounded,
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsTile(
                label: 'Pending payout',
                value: 'KES ${pendingPayout.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.providerAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.providerAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  payoutError != null
                      ? 'Live payout snapshot unavailable. Showing fallback trip estimate for now.'
                      : 'Backend payout snapshot: KES ${earnings.toStringAsFixed(0)} · pending disbursement is ${pendingPayout.toStringAsFixed(0)}.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCards(BuildContext context, bool hasActiveTrip) {
    final items = [
      {'label': 'Deliveries', 'icon': Icons.local_shipping_outlined, 'route': RoutePaths.myTrips, 'color': AppColors.providerAccent},
      {'label': 'Wallet', 'icon': Icons.wallet_rounded, 'route': RoutePaths.transportEarnings, 'color': AppColors.farmerAccent},
      {'label': 'Vehicle', 'icon': Icons.directions_car_rounded, 'route': RoutePaths.profile, 'color': AppColors.buyerAccent},
      {'label': 'Support', 'icon': Icons.help_outline_rounded, 'route': RoutePaths.support, 'color': AppColors.supportAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: items.map((item) {
            return _QuickActionTile(
              label: item['label'] as String,
              icon: item['icon'] as IconData,
              accentColor: item['color'] as Color,
              onTap: () => context.push(item['route'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context, {
    required int activeTrips,
    required double earnings,
    required double todayEarnings,
    required String statusLabel,
    required String weather,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Trips',
                value: activeTrips.toString(),
                icon: Icons.route_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Today',
                value: 'KES ${todayEarnings.toStringAsFixed(0)}',
                icon: Icons.today_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Status',
                value: statusLabel,
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 6),
              Text(
                weather,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Reusable sub‑widgets (same as before, but kept) ────────────────────

class _HeroActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _HeroActionTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  const _AnalyticsTile({required this.label, required this.value, required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  const _QuickActionTile({required this.label, required this.icon, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.dark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}