// lib/features/buyer/widgets/delivery_tracking_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class DeliveryTrackingCard extends StatelessWidget {
  final String driverName;
  final String vehicleLabel;
  final double distanceKm;
  final int etaMinutes;
  final double rating;
  final String? driverImageUrl;
  final String? mapImageUrl;
  final VoidCallback? onCallDriver;

  const DeliveryTrackingCard({
    super.key,
    required this.driverName,
    required this.vehicleLabel,
    required this.distanceKm,
    required this.etaMinutes,
    required this.rating,
    this.driverImageUrl,
    this.mapImageUrl,
    this.onCallDriver,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Map preview
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: mapImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: mapImageUrl!,
                    height: 144,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 144,
                    color: AppColors.light,
                    child: const Center(
                      child: Icon(Icons.map_rounded,
                          color: AppColors.muted, size: 48),
                    ),
                  ),
          ),

          // Driver info row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: driverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: driverImageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: AppColors.light,
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.muted),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_rounded,
                              size: 12, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            vehicleLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onCallDriver != null)
                  GestureDetector(
                    onTap: onCallDriver,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.light,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                _Stat(value: '${distanceKm.toStringAsFixed(1)} km',
                    label: 'Distance'),
                const SizedBox(width: 10),
                _Stat(value: '$etaMinutes min', label: 'ETA'),
                const SizedBox(width: 10),
                _Stat(
                    value: '★ ${rating.toStringAsFixed(1)}',
                    label: 'Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}