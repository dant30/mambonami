import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';

class MarketInsightsStrip extends StatelessWidget {
  final List<Product> products;

  const MarketInsightsStrip({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final averagePrice = products
        .map((product) => product.pricePerUnit)
        .reduce((a, b) => a + b) /
        products.length;
    final cheapest = products.reduce(
      (a, b) => a.pricePerUnit < b.pricePerUnit ? a : b,
    );
    final difference = cheapest.pricePerUnit - averagePrice;
    final percentageChange = averagePrice == 0 ? 0.0 : (difference / averagePrice) * 100;
    final indicatorLabel = percentageChange >= 0
        ? 'below market avg'
        : 'above market avg';
    final indicatorColor = percentageChange >= 0
        ? AppColors.primary
        : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.gold,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today in the market',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cheapest.name} from KES ${cheapest.pricePerUnit.toStringAsFixed(0)}/${cheapest.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentageChange.abs().toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: indicatorColor,
                  ),
                ),
                Text(
                  indicatorLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
