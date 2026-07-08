// lib/features/buyer/widgets/product_search_bar.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilter;
  final String hint;

  const ProductSearchBar({
    super.key,
    required this.controller,
    this.onFilter,
    this.hint = 'Search products, farmers...',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.dark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.muted, size: 18),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),
        ),
        if (onFilter != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}