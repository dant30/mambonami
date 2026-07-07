// mobile/lib/features/buyer/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../config/route_paths.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/dtos/order_dto.dart';
import '../../../data/models/address.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../features/buyer/pages/address_picker_page.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/themes/app_colors.dart';

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
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  double _discountAmount = 0.0;
  bool _promoApplied = false;
  final List<String> _paymentMethods = const ['M-Pesa', 'Card', 'Cash on Delivery'];
  String _selectedPaymentMethod = 'M-Pesa';
  Address? _selectedAddress;
  late final AddressRepository _addressRepository;
  late final OrderRepository _orderRepository;

  // M-Pesa specific
  late String _accountNumber;
  static const String _paybillNumber = '123456';
  bool _copiedPaybill = false;
  bool _copiedAccount = false;
  int _countdownSeconds = 840; // 14 minutes
  Timer? _countdownTimer;
  bool _paymentConfirmed = false;

  @override
  void initState() {
    super.initState();
    _addressRepository = GetIt.instance<AddressRepository>();
    _orderRepository = GetIt.instance<OrderRepository>();
    _addressRepository.init().then((_) {
      final saved = _addressRepository.defaultAddress;
      if (saved != null && mounted) {
        _prefillFromAddress(saved);
      }
    });
    _fetchLocation();
    _generateAccountNumber();
    _startCountdown();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    _timeWindowController.dispose();
    _promoController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _generateAccountNumber() {
    // Generate a random 6-digit number for demo; in production, use server-generated order ID
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
    _accountNumber = 'ORD-$random';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds <= 1) {
        timer.cancel();
        setState(() => _countdownSeconds = 0);
        return;
      }
      setState(() => _countdownSeconds--);
    });
  }

  String get _formattedCountdown {
    final mins = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
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
      setState(() => _scheduledDate = picked);
    }
  }

  void _prefillFromAddress(Address address) {
    setState(() {
      _selectedAddress = address;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _postalCodeController.text = address.postalCode;
      _landmarkController.text = address.landmark ?? '';
    });
  }

  Future<void> _pickSavedAddress() async {
    final selected = await Navigator.of(context).push<Address>(
      MaterialPageRoute(builder: (_) => const AddressPickerPage()),
    );
    if (selected != null) {
      _prefillFromAddress(selected);
    }
  }

  void _applyPromoCode() {
    final cartRepository = GetIt.instance<CartRepository>();
    final code = _promoController.text.trim().toUpperCase();
    final subtotal = cartRepository.subtotal;
    final deliveryFee = subtotal > 200 ? 0.0 : 100.0;

    if (code.isEmpty) {
      setState(() {
        _promoMessage = 'Enter a promo code to save.';
        _discountAmount = 0.0;
        _promoApplied = false;
      });
      return;
    }

    switch (code) {
      case 'MAMBO10':
        setState(() {
          _discountAmount = subtotal * 0.10;
          _promoApplied = true;
          _promoMessage = '10% off applied.';
        });
        break;
      case 'FREESHIP':
        setState(() {
          _discountAmount = deliveryFee;
          _promoApplied = deliveryFee > 0;
          _promoMessage = deliveryFee > 0
              ? 'Free shipping applied.'
              : 'Shipping is already free.';
        });
        break;
      default:
        setState(() {
          _discountAmount = 0.0;
          _promoApplied = false;
          _promoMessage = 'Invalid promo code.';
        });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackbar.showSuccess(context, '$label copied!');
    if (label == 'PayBill') {
      setState(() => _copiedPaybill = true);
      Future.delayed(const Duration(seconds: 2), () => setState(() => _copiedPaybill = false));
    } else if (label == 'Account') {
      setState(() => _copiedAccount = true);
      Future.delayed(const Duration(seconds: 2), () => setState(() => _copiedAccount = false));
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
        paymentMethod: _selectedPaymentMethod,
      );

      final order = await orderRepository.createOrder(request);
      cartRepository.clear();

      if (mounted) {
        final orderUuid = order['order_uuid']?.toString() ?? order['uuid']?.toString() ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (orderUuid.isNotEmpty) {
          context.go(RoutePaths.orderConfirmationPath(orderUuid));
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
    final subtotal = cartRepository.subtotal;
    final deliveryFee = subtotal > 200 ? 0.0 : 100.0;
    final discount = _discountAmount.clamp(0.0, subtotal + deliveryFee);
    final total = subtotal - discount + deliveryFee;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'M-Pesa Payment',
        showBackButton: true,
        fallbackRoute: RoutePaths.buyerDashboard,
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

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Gradient Header (matches React prototype) ───────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/icons/secure_payment_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pay via M-Pesa',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Funds held securely in escrow',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── M-Pesa Instructions ──────────────────────────────
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'FOLLOW THESE STEPS',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._buildSteps(),
                          const SizedBox(height: 16),
                          // PayBill & Account row
                          Row(
                            children: [
                              Expanded(
                                child: _InfoBox(
                                  label: 'Paybill Number',
                                  value: _paybillNumber,
                                  onCopy: () => _copyToClipboard(_paybillNumber, 'PayBill'),
                                  isCopied: _copiedPaybill,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoBox(
                                  label: 'Account Number',
                                  value: _accountNumber,
                                  onCopy: () => _copyToClipboard(_accountNumber, 'Account'),
                                  isCopied: _copiedAccount,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Expiry countdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, color: AppColors.gold),
                                const SizedBox(width: 8),
                                Text(
                                  'Payment expires in',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Text(
                                  _formattedCountdown,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Payment Summary ──────────────────────────────────
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Payment Summary',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _summaryRow(context, 'Subtotal', 'Ksh ${subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          _summaryRow(context, 'Delivery Fee', deliveryFee == 0 ? 'Free' : 'Ksh ${deliveryFee.toStringAsFixed(2)}'),
                          if (discount > 0) ...[
                            const SizedBox(height: 10),
                            _summaryRow(context, 'Discount', '-Ksh ${discount.toStringAsFixed(2)}'),
                          ],
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

                    // ─── Promo Code ────────────────────────────────────────
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer_outlined, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Promo Code',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter promo code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _applyPromoCode,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                ),
                                child: const Text('Apply'),
                              ),
                            ],
                          ),
                          if (_promoMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _promoMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _promoApplied ? Colors.green : theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Escrow Info Banner ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your payment is held in escrow by MAMBONAMI until delivery is confirmed. You can dispute within 48 hours of delivery.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── Delivery Details (collapsible or always visible) ──
                    const SizedBox(height: 16),
                    CustomCard(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Delivery Details',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Location Status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          _currentPosition != null
                                              ? Icons.check_circle
                                              : Icons.warning_amber_rounded,
                                          color: _currentPosition != null ? Colors.green : Colors.orange,
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

                            // Address fields
                            TextFormField(
                              controller: _streetController,
                              decoration: const InputDecoration(
                                labelText: 'Street address',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              validator: (value) => value?.trim().isEmpty == true ? 'Enter a street address' : null,
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
                                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a city' : null,
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
                                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a postal code' : null,
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
                                    hintText: _scheduledDate == null
                                        ? 'Choose delivery date'
                                        : DateFormat.yMMMd().format(_scheduledDate!),
                                    prefixIcon: const Icon(Icons.calendar_today),
                                  ),
                                  validator: (_) => _scheduledDate == null ? 'Choose a delivery date' : null,
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
                              validator: (value) => value?.trim().isEmpty == true ? 'Enter a delivery window' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Sticky "I Have Paid — Confirm" Button ────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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
                          label: 'I Have Paid — Confirm',
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

  List<Widget> _buildSteps() {
    const steps = [
      'Open your M-Pesa app or dial *334#',
      'Select Lipa na M-Pesa → Pay Bill',
      'Enter Business Number: 123456',
      'Enter Account Number: ORD-XXXXX',
      'Enter Amount: KES X,XXX',
      'Enter your M-Pesa PIN and confirm',
    ];
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.dark,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isTotal ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.75),
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

// ─── Helper Widget ──────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool isCopied;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.onCopy,
    required this.isCopied,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  isCopied ? Icons.check_circle : Icons.copy,
                  color: isCopied ? AppColors.success : AppColors.muted,
                  size: 16,
                ),
                onPressed: onCopy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Copy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}