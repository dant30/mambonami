import 'package:flutter/material.dart';

import '../../../data/models/order.dart';

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
        return Theme.of(context).colorScheme.primary;
      case 'confirmed':
        return Theme.of(context).colorScheme.secondary;
      case 'pending':
      default:
        return Theme.of(context).colorScheme.tertiaryContainer;
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Farmer: ${subOrder.farmerName}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text('${subOrder.items.length} item(s)', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text('Subtotal: Ksh ${subOrder.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Text(
                  subOrder.items.map((item) => '${item.quantity.toStringAsFixed(0)}x ${item.productName}').join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

