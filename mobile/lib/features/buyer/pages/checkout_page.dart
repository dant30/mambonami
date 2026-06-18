// mobile/lib/features/buyer/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/dtos/order_dto.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _timeWindowController = TextEditingController();
  DateTime? _scheduledDate;
  bool _isSubmitting = false;
  bool _isLocationLoading = false;
  Position? _currentPosition;
  String _locationStatus = 'Fetching location...';
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    _timeWindowController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permission required';
          _isLocationLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _currentPosition = position;
        _locationStatus = '📍 Location detected';
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = '⚠️ Could not detect location';
        _isLocationLoading = false;
      });
    }
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
      messenger.showSnackBar(const SnackBar(
        content: Text('Please complete the checkout form.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (_currentPosition == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Location is required. Please enable GPS.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (cartRepository.items.value.isEmpty) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Your cart is empty.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final request = CreateOrderRequest(
        items: cartRepository.items.value
            .map((item) => CartItemDto(
                  productUuid: item.product.uuid,
                  quantity: item.quantity,
                ))
            .toList(),
        deliveryAddress: _buildDeliveryAddress(),
        deliveryStreet: _streetController.text.trim(),
        deliveryCity: _cityController.text.trim(),
        deliveryPostalCode: _postalCodeController.text.trim(),
        deliveryLandmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        deliveryLat: _currentPosition!.latitude,
        deliveryLng: _currentPosition!.longitude,
        scheduledDate: DateFormat('yyyy-MM-dd').format(_scheduledDate!),
        scheduledTimeWindow: _timeWindowController.text.trim(),
      );

      final order = await orderRepository.createOrder(request);
      cartRepository.clear();
      
      if (mounted) {
        final orderUuid = order['uuid']?.toString() ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (orderUuid.isNotEmpty) {
          context.go(RoutePaths.orderTrackingPath(orderUuid));
        }
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text('❌ Unable to place order: $error'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _buildDeliveryAddress() {
    final segments = [
      _streetController.text.trim(),
      _cityController.text.trim(),
      _postalCodeController.text.trim(),
    ].where((segment) => segment.isNotEmpty).toList();

    if (_landmarkController.text.trim().isNotEmpty) {
      segments.add('Landmark: ${_landmarkController.text.trim()}');
    }

    return segments.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartRepository = GetIt.instance<CartRepository>();
    final dateText = _scheduledDate == null
        ? 'Choose delivery date'
        : DateFormat.yMMMd().format(_scheduledDate!);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
        showNotificationAction: true,
        showBackButton: true,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartRepository.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'Cart is empty',
              description: 'Add items to your cart before completing checkout.',
              icon: Icons.shopping_basket_outlined,
              buttonText: 'Shop now',
              onButtonPressed: null,
            );
          }

          final subtotal = cartRepository.subtotal;
          final total = subtotal > 200 ? subtotal : subtotal + 100;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Indicator
                    _buildStepIndicator(context),
                    const SizedBox(height: 20),

                    // Order Summary Card
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Order Summary',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _summaryRow(
                              context, 'Items', '${cartRepository.itemCount}'),
                          const SizedBox(height: 10),
                          _summaryRow(context, 'Subtotal',
                              'Ksh ${subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          _summaryRow(context, 'Delivery',
                              subtotal > 200 ? 'Free' : 'Ksh 100'),
                          const Divider(height: 20),
                          _summaryRow(
                            context,
                            'Total',
                            'Ksh ${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery Details
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('Delivery Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Location Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentPosition != null
                                    ? Colors.green.withOpacity(0.08)
                                    : Colors.orange.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _currentPosition != null
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _isLocationLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          _currentPosition != null
                                              ? Icons.check_circle
                                              : Icons.warning_amber_rounded,
                                          color: _currentPosition != null
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _locationStatus,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (_currentPosition == null && !_isLocationLoading)
                                    TextButton(
                                      onPressed: _fetchLocation,
                                      child: const Text('Retry'),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Address Fields
                            TextFormField(
                              controller: _streetController,
                              decoration: const InputDecoration(
                                labelText: 'Street address',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              validator: (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Enter a street address'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City',
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                    validator: (value) =>
                                        value?.trim().isEmpty == true
                                            ? 'Enter a city'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _postalCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Postal code',
                                      prefixIcon: Icon(Icons.code),
                                    ),
                                    validator: (value) =>
                                        value?.trim().isEmpty == true
                                            ? 'Enter a postal code'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _landmarkController,
                              decoration: const InputDecoration(
                                labelText: 'Landmark (optional)',
                                prefixIcon: Icon(Icons.flag_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Delivery date',
                                    hintText: dateText,
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                  ),
                                  validator: (_) => _scheduledDate == null
                                      ? 'Choose a delivery date'
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _timeWindowController,
                              decoration: const InputDecoration(
                                labelText: 'Preferred time window',
                                hintText: 'e.g. 9am - 12pm',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              validator: (value) =>
                                  value?.trim().isEmpty == true
                                      ? 'Enter a delivery window'
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Checkout Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: _isSubmitting
                      ? const LoadingIndicator(
                          message: 'Placing order...',
                          compact: true,
                        )
                      : CustomButton(
                          label: 'Place Order (Ksh ${total.toStringAsFixed(2)})',
                          onPressed: _submitOrder,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final steps = ['Address', 'Review', 'Confirm'];
    
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: _currentStep > index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.75),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}