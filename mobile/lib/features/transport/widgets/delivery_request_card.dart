// mobile/lib/features/transport/widgets/delivery_request_card.dart
import 'package:flutter/material.dart';
import '../../../data/models/trip.dart';
import '../../../shared/themes/app_colors.dart';

class DeliveryRequestCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DeliveryRequestCard({
    super.key,
    required this.trip,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickupLabel = trip.pickupLat != null && trip.pickupLng != null ? 'Pickup point' : 'Farm';
    final deliveryLabel = trip.deliveryLat != null && trip.deliveryLng != null ? 'Delivery point' : 'Customer';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: AppColors.providerAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW DELIVERY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'KES ${trip.agreedFee?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Text('Farmer', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                pickupLabel,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Text('Customer', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                deliveryLabel,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${trip.distanceKm?.toStringAsFixed(1) ?? '—'} km · ETA ${trip.etaMinutes ?? '—'} min',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.providerAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}