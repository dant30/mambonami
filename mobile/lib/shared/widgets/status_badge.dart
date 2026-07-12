// mobile/lib/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;
  const StatusBadge({super.key, required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12, vertical: small ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 8 : 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}