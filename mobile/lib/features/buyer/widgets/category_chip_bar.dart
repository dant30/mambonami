// lib/features/buyer/widgets/category_chip_bar.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final List<IconData?>? icons;
  final int selected;
  final ValueChanged<int> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = i == selected;
          final icon = icons != null && i < icons!.length ? icons![i] : null;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.light,
                borderRadius: BorderRadius.circular(99),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14,
                      color: isActive ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    categories[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}