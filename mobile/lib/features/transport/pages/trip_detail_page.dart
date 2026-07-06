// mobile/lib/features/transport/pages/trip_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';

class TripDetailPage extends StatefulWidget {
  final String tripUuid;

  const TripDetailPage({super.key, required this.tripUuid});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  int? _waitingGraceMinutes;

  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(FetchTripDetailEvent(widget.tripUuid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Trip Details'),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is ArriveAtFarmSuccess) {
            _waitingGraceMinutes = state.response.waitingGraceMinutes;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.response.message}. Grace period: ${state.response.waitingGraceMinutes ?? 0} minutes.',
                ),
              ),
            );
            context.read<TripBloc>().add(FetchTripDetailEvent(widget.tripUuid));
          } else if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const LoadingIndicator();
          } else if (state is TripDetailLoaded) {
            final trip = state.trip;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context, trip),
                  const SizedBox(height: 16),
                  _buildLocationCard(context, trip),
                  const SizedBox(height: 16),
                  _buildMapCard(context, trip),
                  const SizedBox(height: 16),
                  _buildTimelineCard(context, trip),
                  const SizedBox(height: 16),
                  _buildActionButtons(context, trip),
                ],
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

  Widget _buildStatusCard(BuildContext context, var trip) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(trip.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trip.status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(trip.status),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (trip.driverName != null || trip.vehiclePlate != null || trip.etaMinutes != null || trip.distanceKm != null)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (trip.driverName != null && trip.driverName!.isNotEmpty)
                    _buildInfoChip(Icons.person_outline, 'Driver ${trip.driverName!}'),
                  if (trip.vehiclePlate != null && trip.vehiclePlate!.isNotEmpty)
                    _buildInfoChip(Icons.local_shipping_outlined, trip.vehiclePlate!),
                  if (trip.etaMinutes != null)
                    _buildInfoChip(Icons.access_time, '${trip.etaMinutes!} min ETA'),
                  if (trip.distanceKm != null)
                    _buildInfoChip(Icons.route_outlined, '${trip.distanceKm!.toStringAsFixed(1)} km'),
                ],
              ),
            const SizedBox(height: 12),
            if (trip.agreedFee != null)
              Row(
                children: [
                  Icon(Icons.attach_money, size: 20, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Agreed fee: ${trip.agreedFee?.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            if (trip.waitingSurcharge != null && trip.waitingSurcharge! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting surcharge: ${trip.waitingSurcharge?.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (_waitingGraceMinutes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.timelapse, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Grace window: $_waitingGraceMinutes mins',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, var trip) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Locations',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 24, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup',
                          style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        '${trip.pickupLat?.toStringAsFixed(2)}, ${trip.pickupLng?.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 24, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery',
                          style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        '${trip.deliveryLat?.toStringAsFixed(2)}, ${trip.deliveryLng?.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trip.currentLat != null && trip.currentLng != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 24, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current location', style: Theme.of(context).textTheme.labelSmall),
                        Text('${trip.currentLat!.toStringAsFixed(2)}, ${trip.currentLng!.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, var trip) {
    if (trip.pickupLat == null || trip.pickupLng == null || trip.deliveryLat == null || trip.deliveryLng == null) {
      return const SizedBox();
    }

    final pickup = LatLng(trip.pickupLat!, trip.pickupLng!);
    final delivery = LatLng(trip.deliveryLat!, trip.deliveryLng!);
    final distanceKm = _calculateDistanceKm(pickup, delivery);
    final etaText = _formatEta(distanceKm);
    final midpoint = LatLng(
      (pickup.latitude + delivery.latitude) / 2,
      (pickup.longitude + delivery.longitude) / 2,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route & ETA',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: midpoint, zoom: 10),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: pickup,
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('delivery'),
                    position: delivery,
                    infoWindow: const InfoWindow(title: 'Delivery'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
            const SizedBox(height: 12),
            Text('Distance: ${distanceKm.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Estimated ETA: $etaText',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Open in Maps'),
                    onPressed: () => _openNavigation(trip),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  double _calculateDistanceKm(LatLng start, LatLng end) {
    final meters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return meters / 1000;
  }

  String _formatEta(double distanceKm) {
    const averageSpeedKmh = 40.0;
    final minutes = (distanceKm / averageSpeedKmh) * 60;
    final rounded = minutes < 5 ? 5 : minutes.round();
    return '$rounded min';
  }

  Future<void> _openNavigation(var trip) async {
    final origin = '${trip.pickupLat},${trip.pickupLng}';
    final destination = '${trip.deliveryLat},${trip.deliveryLng}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving',
    );

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open navigation app.')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildTimelineCard(BuildContext context, var trip) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (trip.pickedUpAt != null)
              Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Picked up: ${trip.pickedUpAt?.toLocal().toString().split('.')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            if (trip.deliveredAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 20, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delivered: ${trip.deliveredAt?.toLocal().toString().split('.')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, var trip) {
    if (trip.status == 'assigned') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  context.read<TripBloc>().add(ArriveAtFarmEvent(trip.uuid)),
              child: const Text('Arrived at Farm'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(RoutePaths.pickupPath(trip.uuid)),
              child: const Text('Start Pickup'),
            ),
          ),
        ],
      );
    }

    if (trip.status == 'picked_up') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.go(RoutePaths.deliveryPath(trip.uuid)),
          child: const Text('Start Delivery'),
        ),
      );
    }

    return const SizedBox();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
