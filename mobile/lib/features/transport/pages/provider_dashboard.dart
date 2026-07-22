// mobile/lib/features/transport/pages/provider_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/payout_summary.dart';
import '../../../data/models/trip.dart';
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
    context.read<TripBloc>().add(FetchMyTripsEvent());
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
    final tripState = context.watch<TripBloc>().state;

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

    final trips = tripState is MyTripsLoaded ? tripState.trips : <Trip>[];
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

    return Scaffold(
      drawer: const AppDrawer(),
      body: AppScreen(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TripBloc>().add(FetchMyTripsEvent());
            await _loadPayoutSummary();
          },
          color: AppColors.providerAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                if (vehicleType != null) ...[
                  _buildVehicleCard(
                    context,
                    vehicleType,
                    licensePlate,
                    rating,
                    completedDeliveries,
                  ),
                  const SizedBox(height: 12),
                ],
                if (activeTrip != null)
                  _buildActiveTripBanner(context, activeTrip)
                else if (!_isOnline)
                  _buildOfflineBanner(context),
                const SizedBox(height: 12),
                if (activeTrip != null) ...[
                  _buildLiveMapPreview(context, activeTrip),
                  const SizedBox(height: 12),
                ],
                _buildHeroCard(context, activeTrips, summaryToday),
                const SizedBox(height: 18),
                _buildEarningsAnalyticsStrip(
                  context,
                  todayEarnings: summaryToday,
                  completedTrips: summaryCompletedCount,
                  pendingPayout: summaryPendingPayout,
                  earnings: summaryTotalRevenue,
                  payoutError: summaryErrorText,
                ),
                const SizedBox(height: 18),
                _buildQuickAccessCards(context),
                const SizedBox(height: 18),
                _buildStatsSection(
                  context,
                  activeTrips: activeTrips,
                  earnings: earnings,
                  todayEarnings: todayEarnings,
                  statusLabel: statusLabel,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

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

  Widget _buildActiveTripBanner(BuildContext context, Trip trip) {
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
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.providerAccent,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pickup location',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Delivery location',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                'ETA ${trip.etaMinutes ?? '—'} min · ${trip.distanceKm?.toStringAsFixed(1) ?? '—'} km',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push(RoutePaths.tripDetailPath(trip.uuid)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text(
                  'View →',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
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

  Widget _buildHeroCard(
    BuildContext context,
    int activeTrips,
    double todayEarnings,
  ) {
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
                    const Text(
                      'Delivery Control',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeTrips > 0
                          ? '${activeTrips} trip${activeTrips == 1 ? '' : 's'} in motion'
                          : 'Ready to accept new orders',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
                        alignment:
                            _isOnline ? Alignment.centerRight : Alignment.centerLeft,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                    const Icon(
                      Icons.today_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Today: KES ${todayEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.gold,
                    ),
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

  Widget _buildQuickAccessCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            _QuickActionTile(
              label: 'Available',
              icon: Icons.inventory_2_outlined,
              accentColor: AppColors.providerAccent,
              onTap: () => context.push(RoutePaths.availableOrders),
            ),
            _QuickActionTile(
              label: 'Trips',
              icon: Icons.route_outlined,
              accentColor: AppColors.buyerAccent,
              onTap: () => context.push(RoutePaths.myTrips),
            ),
            _QuickActionTile(
              label: 'Earnings',
              icon: Icons.attach_money_rounded,
              accentColor: AppColors.farmerAccent,
              onTap: () => context.push(RoutePaths.transportEarnings),
            ),
            _QuickActionTile(
              label: 'Wallet',
              icon: Icons.wallet_rounded,
              accentColor: AppColors.supportAccent,
              onTap: () => context.push(RoutePaths.transportEarnings),
            ),
          ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
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
      ],
    );
  }
}

class _HeroActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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

  const _AnalyticsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
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

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
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
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
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

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
