import 'package:flutter/material.dart';

class ProductCreatePage extends StatelessWidget {
	const ProductCreatePage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Create Product')),
			body: const Center(child: Text('Product create (placeholder)')),
		);
	}
}
