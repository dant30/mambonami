import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/product.dart';

class FarmerProductCard extends StatelessWidget {
	final Product product;
	final VoidCallback? onEdit;
	final VoidCallback? onTap;

	const FarmerProductCard({
		super.key,
		required this.product,
		this.onEdit,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			clipBehavior: Clip.antiAlias,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
			elevation: 2,
			child: InkWell(
				borderRadius: BorderRadius.circular(18),
				onTap: onTap ?? () => context.go('/farmer/products/${product.uuid}/edit', extra: product),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
							AspectRatio(
								aspectRatio: 4 / 3,
								child: Image.network(
									product.imageUrl!,
									fit: BoxFit.cover,
									errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 42)),
								),
							)
						else
							Container(
								height: 120,
								color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
								child: const Center(child: Icon(Icons.grass, size: 42)),
							),
						Padding(
							padding: const EdgeInsets.all(14),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										product.displayName,
										style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									),
									const SizedBox(height: 8),
									Row(
										children: [
											Expanded(
												child: Text(
													'₦${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
													style: Theme.of(context).textTheme.bodyMedium,
												),
											),
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
												decoration: BoxDecoration(
													color: product.isActive ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.16),
													borderRadius: BorderRadius.circular(12),
												),
												child: Text(
													product.isActive ? 'Active' : 'Inactive',
													style: Theme.of(context).textTheme.labelSmall?.copyWith(
														color: product.isActive ? Colors.green.shade700 : Colors.grey.shade700,
														fontWeight: FontWeight.w700,
													),
												),
											),
										],
									),
									const SizedBox(height: 8),
									Text(
										'${product.availableQuantity.toStringAsFixed(2)} ${product.unit} available',
										style: Theme.of(context).textTheme.bodySmall,
									),
									const SizedBox(height: 12),
									Row(
										children: [
											Expanded(
												child: TextButton.icon(
													onPressed: onEdit ?? () => context.go('/farmer/products/${product.uuid}/edit', extra: product),
													icon: const Icon(Icons.edit, size: 18),
													label: const Text('Edit'),
												),
											),
										],
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

