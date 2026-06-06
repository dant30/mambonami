// mobile/lib/features/transport/widgets/trip_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final bool showActions;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip #${trip.uuid.substring(0, 8)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order: #${trip.order}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.62),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(trip.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(trip.status)
                            .withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      trip.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(trip.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.trip_origin,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pickup: (${trip.pickupLat?.toStringAsFixed(2) ?? 'N/A'}, ${trip.pickupLng?.toStringAsFixed(2) ?? 'N/A'})',
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery: (${trip.deliveryLat?.toStringAsFixed(2) ?? 'N/A'}, ${trip.deliveryLng?.toStringAsFixed(2) ?? 'N/A'})',
                      style: theme.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (trip.pickedUpAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Picked up: ${trip.pickedUpAt?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (trip.deliveredAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivered: ${trip.deliveredAt?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (showActions)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: onTap,
                        child: const Text('View details'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
