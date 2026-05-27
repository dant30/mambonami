import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

class ProductEditPage extends StatelessWidget {
	final String productUuid;
	final Product? initialProduct;

	const ProductEditPage({super.key, required this.productUuid, this.initialProduct});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Edit Product')),
			body: Center(child: Text('Edit product $productUuid (placeholder)')),
		);
	}
}
