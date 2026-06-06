// mobile/lib/features/transport/pages/earnings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/trip.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/earnings_widgets.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../../../blocs/trip/trip_bloc.dart';

class TransportEarningsPage extends StatefulWidget {
  const TransportEarningsPage({super.key});

  @override
  State<TransportEarningsPage> createState() => _TransportEarningsPageState();
}

class _TransportEarningsPageState extends State<TransportEarningsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(FetchMyTripsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: 'Earnings', showNotificationAction: true),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading || state is TripInitial) {
            return const LoadingIndicator(message: 'Loading earnings');
          }

          if (state is TripError) {
            return AppErrorWidget(message: state.message);
          }

          final trips = state is MyTripsLoaded ? state.trips : <Trip>[];
          final completed = trips.where((trip) => trip.deliveredAt != null).toList();
          final active = trips.where((trip) => trip.deliveredAt == null).toList();
          final total = _totalEarnings(completed);
          final pending = _totalEarnings(active);

          return AppScreen(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EarningsHero(
                  label: 'Transport earnings',
                  amount: 'Ksh ${total.toStringAsFixed(2)}',
                  icon: Icons.payments_outlined,
                  stats: [
                    DashboardStat(
                      label: 'Completed',
                      value: completed.length.toString(),
                      icon: Icons.verified_outlined,
                    ),
                    DashboardStat(
                      label: 'Pending',
                      value: 'Ksh ${pending.toStringAsFixed(0)}',
                      icon: Icons.pending_actions_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                EarningsBreakdownCard(
                  title: 'Breakdown',
                  rows: [
                    EarningsBreakdownRow(
                      label: 'Completed Trips',
                      count: '${completed.length} trip(s)',
                      amount: 'Ksh ${total.toStringAsFixed(2)}',
                      icon: Icons.route_outlined,
                    ),
                    EarningsBreakdownRow(
                      label: 'Pending Payments',
                      count: '${active.length} trip(s)',
                      amount: 'Ksh ${pending.toStringAsFixed(2)}',
                      icon: Icons.schedule_outlined,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _totalEarnings(List<Trip> trips) {
    return trips.fold<double>(
      0,
      (sum, trip) => sum + (trip.agreedFee ?? 0) + (trip.waitingSurcharge ?? 0),
    );
  }
}
