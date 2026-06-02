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
      if (widget.trip.pickupLat == null || widget.trip.pickupLng == null)
        return;
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
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
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
                        'Order #${trip.order}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${trip.status}',
                        style: Theme.of(context).textTheme.bodySmall,
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
                      _getStatusColor(trip.status).withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (trip.pickupLat != null && trip.pickupLng != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pickup: (${trip.pickupLat?.toStringAsFixed(2)}, ${trip.pickupLng?.toStringAsFixed(2)})',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_distanceKm != null) ...[
                      const SizedBox(width: 8),
                      Text('${_distanceKm!.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]
                  ],
                ),
              ),
            if (trip.deliveryLat != null && trip.deliveryLng != null)
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: (${trip.deliveryLat?.toStringAsFixed(2)}, ${trip.deliveryLng?.toStringAsFixed(2)})',
                      style: Theme.of(context).textTheme.bodySmall,
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
                    Icon(Icons.attach_money,
                        size: 18, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Fee: ${trip.agreedFee?.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
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
                    child: const Text('Accept'),
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
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
