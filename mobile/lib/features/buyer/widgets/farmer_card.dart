// lib/features/buyer/widgets/farmer_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class FarmerCard extends StatelessWidget {
  final String farmerName;
  final String farmLocation;
  final double distanceKm;
  final bool isVerified;
  final String? imageUrl;
  final VoidCallback? onTap;

  const FarmerCard({
    super.key,
    required this.farmerName,
    required this.farmLocation,
    required this.distanceKm,
    this.isVerified = false,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Farmer avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 24),
                    ),
            ),
            const SizedBox(width: 12),

            // Name + location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 2),
                      Text(
                        '$farmLocation · ${distanceKm.toStringAsFixed(1)} km',
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

            // Verified badge
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '✓ Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}