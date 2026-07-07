// mobile/lib/features/buyer/widgets/order_status_timeline.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/themes/app_colors.dart';

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusEvent> events;

  const OrderStatusTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isLast = index == events.length - 1;
        final isCompleted = event.completed;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline icon & line
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    border: Border.all(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? AppColors.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w400,
                            color: isCompleted
                                ? AppColors.dark
                                : AppColors.muted,
                          ),
                        ),
                        if (event.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LIVE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (event.timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy • hh:mm a').format(event.timestamp!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted.withOpacity(0.6),
                        ),
                      ),
                    ],
                    if (event.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class OrderStatusEvent {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool completed;
  final bool isActive;

  OrderStatusEvent({
    required this.title,
    this.description,
    this.timestamp,
    this.completed = false,
    this.isActive = false,
  });
}