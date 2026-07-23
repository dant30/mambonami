// lib/features/profile/widgets/profile_stat_tile.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class ProfileStatTile extends StatelessWidget {
  final String value;
  final String label;
  const ProfileStatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: CustomCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
}