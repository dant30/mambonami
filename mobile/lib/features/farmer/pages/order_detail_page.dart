import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is SubOrderConfirmed && state.subOrderId == widget.subOrderId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order confirmed.')),
          );
          _fetchSubOrder();
        }
        if (state is SubOrderReady && state.subOrderId == widget.subOrderId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order marked as ready.')),
          );
          _fetchSubOrder();
        }
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isBusy = state is OrderLoading || _isLoadingDetail;

        if (_loadingError != null) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Order Request Details'),
            drawer: const AppDrawer(),
            body: Center(child: Text(_loadingError!)),
          );
        }

        if (_subOrder == null) {
          return const Scaffold(
            appBar: CustomAppBar(title: 'Order Request Details'),
            drawer: AppDrawer(),
            body: Center(child: LoadingIndicator()),
          );
        }

        return Scaffold(
          appBar: const CustomAppBar(title: 'Order Request Details'),
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Order #${_subOrder!.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(_subOrder!.status.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Farmer: ${_subOrder!.farmerName}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Ksh ${_subOrder!.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._subOrder!.items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName),
                      subtitle: Text('${item.quantity.toStringAsFixed(0)} × Ksh ${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: Text('Ksh ${item.totalPrice.toStringAsFixed(2)}'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Order activity', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Confirmed at'),
                    subtitle: Text(_formatDate(_subOrder!.confirmedAt)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ready at'),
                    subtitle: Text(_formatDate(_subOrder!.readyAt)),
                  ),
                  const SizedBox(height: 24),
                  if (_subOrder!.isPending)
                    ElevatedButton(
                      onPressed: isBusy ? null : _confirmOrder,
                      child: const Text('Confirm Order'),
                    ),
                  if (_subOrder!.isConfirmed)
                    ElevatedButton(
                      onPressed: isBusy ? null : _markReady,
                      child: const Text('Mark Ready'),
                    ),
                  if (_subOrder!.isReady)
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('Order Ready'),
                    ),
                ],
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
}
