import 'package:flutter/material.dart';

class OrderRequestsPage extends StatelessWidget {
	const OrderRequestsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Order Requests')),
			body: const Center(child: Text('Order requests (placeholder)')),
		);
	}
}
