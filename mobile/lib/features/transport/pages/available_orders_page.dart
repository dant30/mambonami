// mobile/lib/features/transport/pages/available_orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/trip.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
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
      appBar: const CustomAppBar(
          title: 'Available Orders', showNotificationAction: true),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const LoadingIndicator(message: 'Finding available orders');
          } else if (state is AvailableOrdersLoaded) {
            if (state.orders.isEmpty) {
              return EmptyState(
                title: 'No available orders',
                message:
                    'New delivery work will appear here when farms mark orders ready for transport.',
                buttonText: 'Refresh',
                onButtonPressed: () {
                  context.read<TripBloc>().add(FetchAvailableOrdersEvent());
                },
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TripBloc>().add(FetchAvailableOrdersEvent());
              },
              child: AppScreen(
                child: Column(
                  children: [
                    _AvailableOrdersSummary(orders: state.orders),
                    const SizedBox(height: 12),
                    ...state.orders.map(
                      (trip) => OrderOfferCard(
                        trip: trip,
                        onAccept: () {
                          context
                              .read<TripBloc>()
                              .add(AssignOrderEvent(trip.order));
                          CustomSnackbar.showSuccess(
                            context,
                            'Order assigned to you',
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) {
                              context.push(RoutePaths.tripDetailPath(trip.uuid));
                            }
                          });
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

class _AvailableOrdersSummary extends StatelessWidget {
  final List<Trip> orders;

  const _AvailableOrdersSummary({required this.orders});

  @override
  Widget build(BuildContext context) {
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
          value: orders.length.toString(),
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
