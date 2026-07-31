// lib/features/buyer/widgets/order_status_timeline.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class OrderStatusEvent {
  final String title;
  final String? description;
  final String? timestamp;
  final bool isCompleted;
  final bool isActive;

  const OrderStatusEvent({
    required this.title,
    this.description,
    this.timestamp,
    required this.isCompleted,
    this.isActive = false,
  });
}

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusEvent> events;
  const OrderStatusTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (i) {
        final e = events[i];
        final isLast = i == events.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: dot + line
            Column(
              children: [
                _Dot(
                  isCompleted: e.isCompleted,
                  isActive: e.isActive,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 44,
                    color: e.isCompleted
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.light,
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Right column: title + desc + time
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: e.isCompleted
                                    ? AppColors.dark
                                    : AppColors.muted,
                              ),
                        ),
                        if (e.isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.gold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (e.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        e.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    if (e.timestamp != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        e.timestamp!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  const _Dot({required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isCompleted
              ? (isActive ? AppColors.gold : AppColors.primary)
              : AppColors.light,
          shape: BoxShape.circle,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded,
                size: 14, color: Colors.white)
            : Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
      );
}