import 'package:flutter/material.dart';

class EarningsSummary extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;
  final int confirmedOrders;
  final int readyOrders;
  final int pendingOrders;

  const EarningsSummary({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
    required this.confirmedOrders,
    required this.readyOrders,
    required this.pendingOrders,
  });

  Widget _buildMetric(BuildContext context, String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Earnings snapshot', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildMetric(context, 'Total revenue', 'Ksh ${totalRevenue.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetric(context, 'Orders', totalOrders.toString()),
            const SizedBox(width: 12),
            _buildMetric(context, 'Confirmed', confirmedOrders.toString(), color: Theme.of(context).colorScheme.secondary.withOpacity(0.06)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMetric(context, 'Ready', readyOrders.toString(), color: Theme.of(context).colorScheme.primary.withOpacity(0.06)),
            const SizedBox(width: 12),
            _buildMetric(context, 'Pending', pendingOrders.toString(), color: Theme.of(context).colorScheme.secondary.withOpacity(0.06)),
          ],
        ),
      ],
    );
  }
}

