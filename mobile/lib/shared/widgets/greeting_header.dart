// lib/shared/widgets/greeting_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GreetingHeader extends StatelessWidget {
  final String? name;
  final String? subtitle;
  final bool showDate;
  final TextStyle? nameStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? dateStyle;
  final EdgeInsetsGeometry padding;

  const GreetingHeader({
    super.key,
    this.name,
    this.subtitle,
    this.showDate = true,
    this.nameStyle,
    this.subtitleStyle,
    this.dateStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌅';
    return 'Good Night 🌙';
  }

  // You can make this dynamic based on user role or business logic later
  String _defaultSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Fresh harvests are waiting for you.';
    if (hour < 17) return 'Keep your business growing today.';
    if (hour < 21) return "Let's wrap up today's deliveries.";
    return "We'll be ready for tomorrow's market.";
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : 'there';
    final subtitleText = subtitle ?? _defaultSubtitle();
    final dateLabel = DateFormat('EEE, d MMM').format(DateTime.now());

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            style: nameStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitleText,
            style: subtitleStyle ??
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showDate) ...[
            const SizedBox(height: 8),
            Text(
              dateLabel,
              style: dateStyle ??
                  const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}