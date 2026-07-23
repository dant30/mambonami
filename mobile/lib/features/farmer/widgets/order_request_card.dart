// lib/features/farmer/widgets/order_request_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/order.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class OrderRequestCard extends StatelessWidget {
  final SubOrder subOrder;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const OrderRequestCard({
    super.key,
    required this.subOrder,
    this.onConfirm,
    this.onDecline,
    this.onTap,
  });

  // Compute status color
  Color _statusColor() {
    switch (subOrder.status.toLowerCase()) {
      case 'ready':
        return AppColors.primary;
      case 'confirmed':
        return AppColors.secondary;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel() {
    switch (subOrder.status.toLowerCase()) {
      case 'ready':
        return 'Ready';
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  // Time ago
  String _timeAgo() {
    final date = subOrder.createdAt; // or confirmedAt, etc.
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // Pickup deadline – from order.scheduledDate or subOrder.readyAt
  String? _pickupDeadline() {
    if (subOrder.readyAt != null) {
      return DateFormat('EEE, MMM d • h:mm a').format(subOrder.readyAt!);
    }
    return null;
  }

  // Driver info – simplified (no assignment data in SubOrder)
  String? _driverInfo() {
    return null; // Not available in current SubOrder model
  }

  // Priority chip – if ready deadline is within 2 hours, mark URGENT
  bool _isUrgent() {
    if (subOrder.readyAt != null) {
      final diff = subOrder.readyAt!.difference(DateTime.now());
      return diff.inHours <= 2 && diff.inHours >= 0;
    }
    return false;
  }

  // Progress step – based on status
  int _progressStep() {
    switch (subOrder.status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'ready':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor();
    final isPending = subOrder.isPending;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order #, buyer, time, status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${subOrder.id}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 12, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            subOrder.farmerName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _timeAgo(),
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 10),

            // Product summary
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    subOrder.items.map((item) => '${item.quantity}x ${item.productName}').join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Total and pickup deadline
            Row(
              children: [
                Text(
                  'KES ${subOrder.subtotal.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                if (_pickupDeadline() != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        _pickupDeadline()!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Driver info or waiting
            if (_driverInfo() != null)
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Assigned: ${_driverInfo()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Waiting for transporter',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 10),

            // Priority chip (if urgent)
            if (_isUrgent())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Progress indicator (simple dots)
            Row(
              children: [
                _ProgressDot(active: _progressStep() >= 0),
                _ProgressLine(active: _progressStep() >= 1),
                _ProgressDot(active: _progressStep() >= 1),
                _ProgressLine(active: _progressStep() >= 2),
                _ProgressDot(active: _progressStep() >= 2),
                const Spacer(),
                Text(
                  ['Pending', 'Confirmed', 'Ready'][_progressStep()],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onConfirm,
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onPressed: onDecline,
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Helper widgets for progress dots
class _ProgressDot extends StatelessWidget {
  final bool active;
  const _ProgressDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.light,
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final bool active;
  const _ProgressLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      color: active ? AppColors.primary : AppColors.light,
    );
  }
}