import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';
import 'countdown_timer_widget.dart';
import 'product_grid_tile.dart';

class FlashDealsSection extends StatefulWidget {
  final List<Product> products;

  const FlashDealsSection({super.key, required this.products});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final deals = widget.products.take(4).toList();
    final elapsed = DateTime.now().difference(_startedAt).inSeconds;
    final remaining = (7200 - elapsed).clamp(0, 7200);
    final cardWidth = MediaQuery.of(context).size.width > 360
        ? 160.0
        : (MediaQuery.of(context).size.width * 0.46).clamp(140.0, 160.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Flash deals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 19),
              const Spacer(),
              CountdownTimerWidget(
                durationSeconds: remaining,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 235,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: ProductGridTile(product: deals[index]),
            ),
          ),
        ),
      ],
    );
  }
}
