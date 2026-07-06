import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/order_request_card.dart';

class OrderRequestsPage extends StatefulWidget {
  const OrderRequestsPage({super.key});

  @override
  State<OrderRequestsPage> createState() => _OrderRequestsPageState();
}

class _OrderRequestsPageState extends State<OrderRequestsPage> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  Future<void> _refresh() async {
    context.read<OrderBloc>().add(FetchFarmerSubOrdersEvent());
  }

  void _openDetail(SubOrder subOrder) {
    context.go(RoutePaths.farmerOrderRequestDetailPath(subOrder.id), extra: subOrder);
  }

  List<SubOrder> _filteredOrders(List<SubOrder> subOrders) {
    final normalized = _selectedFilter.toLowerCase();
    if (normalized == 'all') return subOrders;
    return subOrders.where((subOrder) => subOrder.status.toLowerCase() == normalized).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Order Requests',
        showNotificationAction: true,
        showBackButton: true,
        fallbackRoute: RoutePaths.farmerDashboard,
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const LoadingIndicator();
          }

          if (state is FarmerSubOrdersLoaded) {
            final subOrders = state.subOrders;
            if (subOrders.isEmpty) {
              return EmptyState(
                title: 'No order requests',
                description: 'You have not received any farm orders yet. Check back after your products are listed.',
                icon: Icons.assignment_turned_in_outlined,
                buttonText: 'Refresh list',
                onButtonPressed: _refresh,
              );
            }

            final filteredOrders = _filteredOrders(subOrders);
            final pendingCount = subOrders.where((order) => order.isPending).length;
            final confirmedCount = subOrders.where((order) => order.status.toLowerCase() == 'confirmed').length;
            final readyCount = subOrders.where((order) => order.status.toLowerCase() == 'ready').length;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppGradients.hero,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incoming requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confirm, prep, and fulfill orders without missing your pickup window.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SummaryChip(label: '$pendingCount pending', color: AppColors.warning),
                          _SummaryChip(label: '$confirmedCount confirmed', color: AppColors.secondary),
                          _SummaryChip(label: '$readyCount ready', color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: ['All', 'Pending', 'Confirmed', 'Ready'].map((filter) {
                      final selected = _selectedFilter == filter;
                      return FilterChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                        selectedColor: AppColors.primary.withOpacity(0.16),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.muted, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(title: 'Open requests', subtitle: 'Tap a request to review or act on it'),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: filteredOrders.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: EmptyState(
                                  title: 'No matching requests',
                                  description: 'Try a different filter to see more orders.',
                                  icon: Icons.filter_alt_off,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemBuilder: (context, index) {
                              final subOrder = filteredOrders[index];
                              return OrderRequestCard(subOrder: subOrder, onTap: () => _openDetail(subOrder));
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemCount: filteredOrders.length,
                          ),
                  ),
                ),
              ],
            );
          }

          if (state is OrderError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Unable to load order requests.'));
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
