// mobile/lib/features/transport/widgets/active_trip_banner.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/order.dart';
import '../../../shared/themes/app_colors.dart';

class ActiveTripBanner extends StatelessWidget {
  final Trip trip;
  final Order? order;

  const ActiveTripBanner({
    super.key,
    required this.trip,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final farmerName = order?.subOrders.isNotEmpty == true
        ? order!.subOrders.first.farmerName
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.providerAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.providerAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                color: AppColors.providerAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Trip',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.providerAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.providerAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.providerAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Farmer & produce
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  farmerName ?? 'Farmer',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_grocery_store_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order?.itemsSummary ?? 'Produce',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Customer & amount
          Row(
            children: [
              const Icon(Icons.home_rounded, size: 14, color: AppColors.dark),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order?.buyerName ?? 'Customer',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'KES ${trip.agreedFee?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                'ETA ${trip.etaMinutes ?? '—'} min · ${trip.distanceKm?.toStringAsFixed(1) ?? '—'} km',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => context.push(RoutePaths.tripDetailPath(trip.uuid)),
                child: const Icon(Icons.arrow_forward_rounded, color: AppColors.providerAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}