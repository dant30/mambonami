// lib/features/buyer/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/dtos/order_dto.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/paybill_instructions_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cartRepo = GetIt.I<CartRepository>();
  final _orderRepo = GetIt.I<OrderRepository>();

  String? _orderId;
  String? _paybillAccount;
  bool _creating = false;
  bool _confirming = false;

  double _subtotal = 0.0;
  double _deliveryFee = 0.0;
  double _platformFee = 0.0;
  double get _total => _subtotal + _deliveryFee + _platformFee;

  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  Future<void> _createOrder() async {
    setState(() => _creating = true);
    try {
      final request = CreateOrderRequest(
        items: _cartRepo.allItems
            .map((item) => CartItemDto(productUuid: item.product.uuid, quantity: item.quantity))
            .toList(),
        deliveryAddress: 'Westlands, Nairobi',
        deliveryStreet: 'Westlands',
        deliveryCity: 'Nairobi',
        deliveryPostalCode: '00100',
        deliveryLat: -1.2672,
        deliveryLng: 36.8107,
        scheduledDate: DateTime.now().toIso8601String(),
        scheduledTimeWindow: 'Today',
      );
      final order = await _orderRepo.createOrder(request);
      final orderUuid = order['uuid']?.toString() ?? '';
      final orderId = order['id']?.toString() ?? orderUuid;
      final subtotal = double.tryParse(order['subtotal']?.toString() ?? '') ?? _cartRepo.subtotal;
      final deliveryFee = double.tryParse(order['delivery_fee']?.toString() ?? '') ?? 0.0;
      final platformFee = double.tryParse(order['platform_commission']?.toString() ?? '') ?? 0.0;
      final total = double.tryParse(order['total_amount']?.toString() ?? '') ?? (subtotal + deliveryFee + platformFee);
      _cartRepo.setBackendFeeBreakdown(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        serviceFee: platformFee,
        total: total,
      );
      setState(() {
        _subtotal = subtotal;
        _deliveryFee = deliveryFee;
        _platformFee = platformFee;
        _orderId = orderId;
        _paybillAccount = orderUuid.isEmpty ? 'ORD-XXXXXXXX' : 'ORD-${orderUuid.substring(0, 8).toUpperCase()}';
        _creating = false;
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to create order: $e');
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_orderId == null) return;
    setState(() => _confirming = true);
    try {
      // Poll for payment confirmation or allow manual confirmation
      context
          .read<OrderBloc>()
          .add(ConfirmPaymentEvent(orderId: _orderId!));
      _cartRepo.clear();
      if (mounted) {
        context.go(RoutePaths.orderTrackingPath(_orderId!));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString());
        setState(() => _confirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────
            Container(
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'M-Pesa Payment',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: _creating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Creating your order...',
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        children: [
                          // M-Pesa instructions
                          PaybillInstructionsCard(
                            paybillNumber: '123456',
                            accountNumber: _paybillAccount ?? 'ORD-XXXXXXXX',
                            amount: _total,
                          ),
                          const SizedBox(height: 16),

                          // Payment expiry countdown
                          if (_orderId != null)
                            CustomCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payment expires in',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.dark),
                                  ),
                                  const Spacer(),
                                  CountdownTimerWidget(
                                    durationSeconds: 14 * 60,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.gold,
                                        ),
                                    onExpired: () =>
                                        CustomSnackbar.showError(
                                            context,
                                            'Payment window expired. Please try again.'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Summary card
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Summary',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        )),
                                const SizedBox(height: 12),
                                _Row('Subtotal',
                                    'KES ${_subtotal.toStringAsFixed(0)}'),
                                const SizedBox(height: 5),
                                _Row('Delivery fee',
                                    'KES ${_deliveryFee.toStringAsFixed(0)}'),
                                const SizedBox(height: 5),
                                _Row('Escrow service fee',
                                    'KES ${_platformFee.toStringAsFixed(0)}'),
                                const Divider(
                                    height: 20, color: AppColors.light),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.dark,
                                            )),
                                    Text(
                                      'KES ${_total.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Escrow info banner
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.18)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.shield_rounded,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Your payment is held in escrow by MAMBONAMI until delivery is confirmed. You can raise a dispute within 48 hours.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.muted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // ── Confirm button ─────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              color: Colors.white,
              child: CustomButton(
                label: 'I Have Paid — Confirm',
                isLoading: _confirming,
                onPressed: _orderId != null ? _confirmPayment : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          Text(value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.dark)),
        ],
      );
}