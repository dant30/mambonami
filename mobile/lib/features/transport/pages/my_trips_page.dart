import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
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
            return const LoadingIndicator();
          } else if (state is MyTripsLoaded) {
            if (state.trips.isEmpty) {
              return const EmptyState(message: 'No trips assigned yet');
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TripBloc>().add(FetchMyTripsEvent());
              },
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.of(context).padding.bottom),
                itemCount: state.trips.length,
                itemBuilder: (context, index) {
                  final trip = state.trips[index];
                  return TripCard(
                    trip: trip,
                    onTap: () {
                      context.push(RoutePaths.tripDetailPath(trip.uuid));
                    },
                  );
                },
              ),
            );
          } else if (state is TripError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
