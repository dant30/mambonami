// lib/features/farmer/pages/order_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/loading_indicator.dart';

class OrderDetailPage extends StatefulWidget {
  final int subOrderId;
  final SubOrder? initialSubOrder;

  const OrderDetailPage({
    super.key,
    required this.subOrderId,
    this.initialSubOrder,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  SubOrder? _subOrder;
  bool _isLoadingDetail = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _subOrder = widget.initialSubOrder;
    if (_subOrder == null) {
      _fetchSubOrder();
    }
  }

  Future<void> _fetchSubOrder() async {
    setState(() {
      _isLoadingDetail = true;
      _loadingError = null;
    });

    try {
      final repository = GetIt.instance<OrderRepository>();
      final subOrder = await repository.fetchFarmerSubOrder(widget.subOrderId);
      if (mounted) {
        setState(() {
          _subOrder = subOrder;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingError = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  void _confirmOrder() {
    context.read<OrderBloc>().add(ConfirmSubOrderEvent(widget.subOrderId));
  }

  void _markReady() {
    context.read<OrderBloc>().add(MarkSubOrderReadyEvent(widget.subOrderId));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return DateFormat('dd MMM yyyy • h:mm a').format(date);
  }

  // Computed timeline steps
  int _currentStep() {
    switch (_subOrder?.status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'ready':
        return 2;
      default:
        return 0;
    }
  }

  String _statusLabel() {
    switch (_subOrder?.status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'ready':
        return 'Ready for Pickup';
      default:
        return 'Unknown';
    }
  }

  Color _statusColor() {
    switch (_subOrder?.status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.secondary;
      case 'ready':
        return AppColors.primary;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is SubOrderConfirmed && state.subOrderId == widget.subOrderId) {
          CustomSnackbar.showSuccess(context, 'Order confirmed!');
          _fetchSubOrder();
        }
        if (state is SubOrderReady && state.subOrderId == widget.subOrderId) {
          CustomSnackbar.showSuccess(context, 'Order marked as ready!');
          _fetchSubOrder();
        }
        if (state is OrderError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isBusy = state is OrderLoading || _isLoadingDetail;

        if (_loadingError != null) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Order Details',
              showBackButton: true,
              fallbackRoute: RoutePaths.farmerOrderRequests,
            ),
            drawer: const AppDrawer(),
            body: Center(child: Text(_loadingError!)),
          );
        }

        if (_subOrder == null) {
          return const Scaffold(
            appBar: CustomAppBar(
              title: 'Order Details',
              showBackButton: true,
              fallbackRoute: RoutePaths.farmerOrderRequests,
            ),
            drawer: AppDrawer(),
            body: Center(child: LoadingIndicator()),
          );
        }

        final subOrder = _subOrder!;
        final isPending = subOrder.isPending;
        final isConfirmed = subOrder.isConfirmed;
        final isReady = subOrder.isReady;
        final currentStep = _currentStep();
        final statusColor = _statusColor();

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Order Details',
            showBackButton: true,
            fallbackRoute: RoutePaths.farmerOrderRequests,
          ),
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header card ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.hero,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Order #${subOrder.id}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _statusLabel().toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subtotal: KES ${subOrder.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subOrder.readyAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Ready by ${DateFormat('EEE, MMM d • h:mm a').format(subOrder.readyAt!)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Timeline ────────────────────────────────────────
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTimeline(currentStep),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Items ───────────────────────────────────────────
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...subOrder.items.map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.inventory_2, color: AppColors.primary),
                                title: Text(item.productName),
                                subtitle: Text('${item.quantity} × KES ${item.unitPrice.toStringAsFixed(2)}'),
                                trailing: Text(
                                  'KES ${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  'KES ${subOrder.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Actions ─────────────────────────────────────────
                    if (isPending)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: isBusy ? null : _confirmOrder,
                              child: const Text(
                                'Confirm Order',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            onPressed: isBusy ? null : () {
                              context.read<OrderBloc>().add(DeclineSubOrderEvent(subOrder.id));
                            },
                            child: const Text(
                              'Decline',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      )
                    else if (isConfirmed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: isBusy ? null : _markReady,
                        child: const Text(
                          'Mark as Ready for Pickup',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      )
                    else if (isReady)
                      const Card(
                        color: AppColors.light,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success),
                              SizedBox(width: 8),
                              Text(
                                'Order is ready for pickup',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // ─── Timestamps ──────────────────────────────────────
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.muted,
                                      ),
                                ),
                                Text(
                                  _formatDate(subOrder.createdAt),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (subOrder.confirmedAt != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Confirmed',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.muted,
                                        ),
                                  ),
                                  Text(
                                    _formatDate(subOrder.confirmedAt),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── Timeline builder ──────────────────────────────────────────────────
  Widget _buildTimeline(int currentStep) {
    const steps = [
      {'title': 'Pending', 'icon': Icons.pending_actions_outlined},
      {'title': 'Confirmed', 'icon': Icons.check_circle_outline},
      {'title': 'Ready', 'icon': Icons.inventory_2_outlined},
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentStep;
        return Row(
          children: [
            // Dot
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.light,
                shape: BoxShape.circle,
              ),
              child: Icon(
                steps[i]['icon'] as IconData,
                size: 16,
                color: isActive ? Colors.white : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                steps[i]['title'] as String,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.dark : AppColors.muted,
                ),
              ),
            ),
            // Connector line (if not last)
            if (i < steps.length - 1)
              Container(
                width: 20,
                height: 2,
                color: i < currentStep ? AppColors.primary : AppColors.light,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
          ],
        );
      }),
    );
  }
}