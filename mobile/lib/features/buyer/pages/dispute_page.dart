// mobile/lib/features/buyer/pages/dispute_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../data/dtos/dispute_dto.dart';
import '../../../blocs/dispute/dispute_bloc.dart';

class DisputePage extends StatefulWidget {
  const DisputePage({super.key});

  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orderUuidController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load disputes on init
    context.read<DisputeBloc>().add(const FetchMyDisputesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderUuidController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    
    final request = CreateDisputeRequest(
      orderUuid: _orderUuidController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    
    if (!mounted) return;
    context.read<DisputeBloc>().add(CreateDisputeEvent(request));
  }

  void _onDisputeCreated(BuildContext context) {
    _orderUuidController.clear();
    _subjectController.clear();
    _descriptionController.clear();
    _tabController.animateTo(0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispute submitted successfully')),
    );
    // Refresh disputes list
    context.read<DisputeBloc>().add(const FetchMyDisputesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Disputes',
        showNotificationAction: true,
        showBackButton: true,
        actions: const [CartActionButton()],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Disputes'),
              Tab(text: 'New Dispute'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDisputesListTab(context),
                _buildNewDisputeTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputesListTab(BuildContext context) {
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<DisputeBloc, DisputeState>(
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyDisputesLoaded) {
            if (state.disputes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No disputes yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new dispute if you need help with an order',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.disputes.length,
              itemBuilder: (context, index) {
                final dispute = state.disputes[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dispute.subject,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            _buildStatusBadge(dispute.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dispute.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order: ${dispute.orderUuid.substring(0, 8)}...',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(dispute.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is DisputeError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          return const Center(child: Text('No disputes found'));
        },
      ),
    );
  }

  Widget _buildNewDisputeTab(BuildContext context) {
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeCreated) {
          _onDisputeCreated(context);
        } else if (state is DisputeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need help with an order?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share the issue below and our team will respond shortly.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _orderUuidController,
                    decoration: const InputDecoration(
                      labelText: 'Order UUID',
                      hintText: 'Enter the order ID',
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter order UUID' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g., Item quality issue',
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the issue in detail...',
                    ),
                    maxLines: 6,
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a description' : null,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<DisputeBloc, DisputeState>(
                    builder: (context, state) {
                      final isLoading = state is DisputeLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitDispute,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit Dispute'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = Colors.blue;
        break;
      case 'resolved':
        backgroundColor = Colors.green;
        break;
      case 'closed':
        backgroundColor = Colors.grey;
        break;
      default:
        backgroundColor = Colors.grey[400]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
