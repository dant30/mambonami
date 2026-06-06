// mobile/lib/features/transport/pages/my_trips_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/trip.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../widgets/trip_card.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(FetchMyTripsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Trips', showNotificationAction: true),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const LoadingIndicator(message: 'Loading trips');
          } else if (state is MyTripsLoaded) {
            if (state.trips.isEmpty) {
              return EmptyState(
                title: 'No trips assigned yet',
                message:
                    'Accepted delivery work will appear here with pickup and delivery progress.',
                buttonText: 'Refresh',
                onButtonPressed: () {
                  context.read<TripBloc>().add(FetchMyTripsEvent());
                },
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TripBloc>().add(FetchMyTripsEvent());
              },
              child: AppScreen(
                child: Column(
                  children: [
                    _TripsSummary(trips: state.trips),
                    const SizedBox(height: 12),
                    ...state.trips.map(
                      (trip) => TripCard(
                        trip: trip,
                        onTap: () {
                          context.push(RoutePaths.tripDetailPath(trip.uuid));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is TripError) {
            return AppErrorWidget(message: state.message);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _TripsSummary extends StatelessWidget {
  final List<Trip> trips;

  const _TripsSummary({required this.trips});

  @override
  Widget build(BuildContext context) {
    final delivered = trips.where((trip) => trip.deliveredAt != null).length;
    final active = trips.length - delivered;
    final earned = trips
        .where((trip) => trip.deliveredAt != null)
        .fold<double>(
            0, (sum, trip) => sum + (trip.agreedFee ?? 0) + (trip.waitingSurcharge ?? 0));

    return DashboardStatStrip(
      stats: [
        DashboardStat(
          label: 'Active',
          value: active.toString(),
          icon: Icons.route_outlined,
        ),
        DashboardStat(
          label: 'Delivered',
          value: delivered.toString(),
          icon: Icons.verified_outlined,
        ),
        DashboardStat(
          label: 'Earned',
          value: 'Ksh ${earned.toStringAsFixed(0)}',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }
}
