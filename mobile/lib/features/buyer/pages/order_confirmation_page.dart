import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderUuid;
  const OrderConfirmationPage({super.key, required this.orderUuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Order Confirmed',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Icon(Icons.check_circle_outline, size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Your order is confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Order number: $orderUuid',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              'You can track the delivery and view order status in the Orders section.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Track Order',
              onPressed: () => context.go(RoutePaths.orderTrackingPath(orderUuid)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(RoutePaths.buyerDashboard),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
