import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _timeWindowController = TextEditingController();
  DateTime? _scheduledDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _timeWindowController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _submitOrder() async {
    final cartRepository = GetIt.instance<CartRepository>();
    final orderRepository = GetIt.instance<OrderRepository>();
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate() || _scheduledDate == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please complete the checkout form.')));
      return;
    }

    if (cartRepository.items.value.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(const SnackBar(content: Text('Location permission is required to place the order.')));
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (!mounted) return;

      final request = CreateOrderRequest(
        items: cartRepository.items.value
            .map((item) => CartItemDto(productUuid: item.product.uuid, quantity: item.quantity))
            .toList(),
        deliveryAddress: _addressController.text.trim(),
        deliveryLat: position.latitude,
        deliveryLng: position.longitude,
        scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
        scheduledTimeWindow: _timeWindowController.text.trim(),
      );
      await orderRepository.createOrder(request);
      cartRepository.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Order placed successfully.')));
      if (mounted) {
        context.go(RoutePaths.orders);
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Unable to place order: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartRepository = GetIt.instance<CartRepository>();
    final dateText = _scheduledDate == null ? 'Choose delivery date' : DateFormat.yMMMd().format(_scheduledDate!);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Checkout', showNotificationAction: true),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartRepository.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyState(message: 'Add items to your cart before checkout.');
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Order summary', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('Items: ${cartRepository.itemCount}'),
                  const SizedBox(height: 8),
                  Text('Subtotal: Ksh ${cartRepository.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('Total weight: ${cartRepository.totalWeightKg.toStringAsFixed(2)} kg'),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Delivery address'),
                          validator: (value) => value?.trim().isEmpty == true ? 'Enter a delivery address' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(labelText: 'Delivery date', hintText: dateText),
                          onTap: _selectDate,
                          validator: (_) => _scheduledDate == null ? 'Choose a delivery date' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _timeWindowController,
                          decoration: const InputDecoration(labelText: 'Preferred time window', hintText: 'e.g. 9am - 12pm'),
                          validator: (value) => value?.trim().isEmpty == true ? 'Enter a delivery window' : null,
                        ),
                        const SizedBox(height: 24),
                        _isSubmitting
                            ? const Center(child: LoadingIndicator())
                            : ElevatedButton(
                                onPressed: _submitOrder,
                                child: const Text('Place Order'),
                              ),
                      ],
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

