// mobile/lib/features/transport/widgets/order_offer_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../../../data/models/trip.dart';

class OrderOfferCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const OrderOfferCard({
    super.key,
    required this.trip,
    required this.onAccept,
    this.onDecline,
  });

  @override
  State<OrderOfferCard> createState() => _OrderOfferCardState();
}

class _OrderOfferCardState extends State<OrderOfferCard> {
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _computeDistance();
  }

  Future<void> _computeDistance() async {
    try {
      if (widget.trip.pickupLat == null || widget.trip.pickupLng == null) {
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      final d = _haversineDistance(pos.latitude, pos.longitude,
          widget.trip.pickupLat!, widget.trip.pickupLng!);
      setState(() => _distanceKm = d);
    } catch (_) {
      // ignore errors silently
    }
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        'Trip ${trip.uuid.substring(0, trip.uuid.length > 8 ? 8 : trip.uuid.length)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${trip.status}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    trip.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(trip.status),
                    ),
                  ),
                  backgroundColor:
                      _getStatusColor(trip.status).withValues(alpha: 0.1),
                  side: BorderSide(
                    color: _getStatusColor(trip.status).withValues(alpha: 0.22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (trip.pickupLat != null && trip.pickupLng != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.trip_origin,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pickup: (${trip.pickupLat?.toStringAsFixed(2)}, ${trip.pickupLng?.toStringAsFixed(2)})',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_distanceKm != null) ...[
                      const SizedBox(width: 8),
                      Text('${_distanceKm!.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          )),
                    ]
                  ],
                ),
              ),
            if (trip.deliveryLat != null && trip.deliveryLng != null)
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: (${trip.deliveryLat?.toStringAsFixed(2)}, ${trip.deliveryLng?.toStringAsFixed(2)})',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (trip.agreedFee != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Fee: ${trip.agreedFee?.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.onDecline != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                if (widget.onDecline != null) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    child: const Text('Accept order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        return const Color(0xFF138A4A);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
