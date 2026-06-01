import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../widgets/order_offer_card.dart';

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
      appBar: const CustomAppBar(title: 'Available Orders', showNotificationAction: true),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const LoadingIndicator();
          } else if (state is AvailableOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const EmptyState(message: 'No available orders at the moment');
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TripBloc>().add(FetchAvailableOrdersEvent());
              },
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.of(context).padding.bottom),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final trip = state.orders[index];
                  return OrderOfferCard(
                    trip: trip,
                    onAccept: () {
                      context.read<TripBloc>().add(AssignOrderEvent(trip.order));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order assigned to you!')),
                      );
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          context.push(RoutePaths.tripDetailPath(trip.uuid));
                        }
                      });
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
