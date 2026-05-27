import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {
	const ProductListPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('My Products')),
			body: const Center(child: Text('Farmer product list (placeholder)')),
		);
	}
}
