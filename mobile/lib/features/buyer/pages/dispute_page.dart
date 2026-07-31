// mobile/lib/features/buyer/pages/dispute_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/dispute/dispute_bloc.dart';
import '../../../data/dtos/dispute_dto.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_image_picker.dart';
import '../../../shared/widgets/custom_snackbar.dart';

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
  final List<File> _evidenceImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> _pickImages() async {
    final picked = await CustomImagePicker.pickMultipleImages(maxCount: 5 - _evidenceImages.length);
    if (picked.isNotEmpty) {
      setState(() {
        _evidenceImages.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _evidenceImages.removeAt(index);
    });
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    if (_evidenceImages.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please add at least one evidence photo.');
      return;
    }

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
    setState(() => _evidenceImages.clear());
    _tabController.animateTo(0);
    CustomSnackbar.showSuccess(context, 'Dispute submitted successfully.');
    context.read<DisputeBloc>().add(const FetchMyDisputesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Disputes',
        showNotificationAction: true,
        showBackButton: true,
        actions: [CartActionButton()],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeError) {
          CustomSnackbar.showError(context, 'Error: ${state.message}');
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
                    Icon(Icons.info_outline, size: 48, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No disputes yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new dispute if you need help with an order',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                                style: theme.textTheme.titleMedium?.copyWith(
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
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order: ${dispute.orderUuid.substring(0, 8)}...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(dispute.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('No disputes found'));
        },
      ),
    );
  }

  Widget _buildNewDisputeTab(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeCreated) {
          _onDisputeCreated(context);
        } else if (state is DisputeError) {
          CustomSnackbar.showError(context, 'Error: ${state.message}');
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need help with an order?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share the issue below and our team will respond shortly.',
              style: theme.textTheme.bodyMedium,
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
                  const SizedBox(height: 20),
                  // Evidence photos section
                  _buildEvidenceSection(context),
                  const SizedBox(height: 20),
                  BlocBuilder<DisputeBloc, DisputeState>(
                    builder: (context, state) {
                      final isLoading = state is DisputeLoading;
                      return CustomButton(
                        label: 'Submit Dispute',
                        onPressed: isLoading ? null : _submitDispute,
                        isLoading: isLoading,
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

  Widget _buildEvidenceSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Photos (max 5)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (_evidenceImages.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _evidenceImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _evidenceImages[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        if (_evidenceImages.length < 5)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text('Add Photo (${_evidenceImages.length}/5)'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = AppColors.warning;
        break;
      case 'resolved':
        backgroundColor = AppColors.success;
        break;
      case 'closed':
        backgroundColor = AppColors.muted;
        break;
      default:
        backgroundColor = AppColors.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}