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
        return Theme.of(context).colorScheme.secondary;
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      color: _statusColor(context).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _statusColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Farmer: ${subOrder.farmerName}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('${subOrder.items.length} item(s)', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text('Subtotal: Ksh ${subOrder.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
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
    );
  }
}

