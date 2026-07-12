import 'package:flutter/material.dart';

import '../../../data/models/order.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class OrderRequestCard extends StatelessWidget {
  final SubOrder subOrder;
  final VoidCallback? onTap;

  const OrderRequestCard({
    super.key,
    required this.subOrder,
    this.onTap,
  });

  Color _statusColor(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${subOrder.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Buyer: ${subOrder.farmerName}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('${subOrder.items.length} item(s)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
            Text('Subtotal: KES ${subOrder.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subOrder.items.map((item) => '${item.quantity.toStringAsFixed(0)}x ${item.productName}').join(', '),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

