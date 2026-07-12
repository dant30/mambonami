// lib/features/farmer/pages/product_create_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/utils/image_picker_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _harvestDate = DateTime.now();
  bool _isActive = true;
  File? _selectedImage;
  bool _isLoadingCategories = true;
  List<ProductCategory> _categories = [];
  ProductCategory? _selectedCategory;
  String _selectedUnit = 'kg';

  final List<String> _units = ['kg', 'bunch', 'piece', 'litre', 'tray', 'bag'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final repository = GetIt.instance<ProductRepository>();
      final categories = await repository.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (_) {
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePickerHelper.showImageSourceDialog(context);
    if (file == null) return;
    setState(() {
      _selectedImage = file;
    });
  }

  Future<void> _selectHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());

    if (_selectedCategory == null) {
      CustomSnackbar.showError(context, 'Please select a category.');
      return;
    }
    if (price == null || price <= 0) {
      CustomSnackbar.showError(context, 'Please enter a valid price.');
      return;
    }
    if (quantity == null || quantity <= 0) {
      CustomSnackbar.showError(context, 'Please enter a valid quantity.');
      return;
    }

    final productData = <String, dynamic>{
      'category': _selectedCategory!.id,
      'name': _nameController.text.trim(),
      'price_per_unit': price,
      'available_quantity': quantity,
      'unit': _selectedUnit,
      'harvest_date': _harvestDate.toIso8601String().split('T').first,
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'is_active': _isActive,
      if (_selectedImage != null) 'image': _selectedImage,
    };

    context.read<ProductBloc>().add(CreateProductEvent(productData));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCreated) {
          CustomSnackbar.showSuccess(
              context, '"${state.product.displayName}" created successfully.');
          context.go(RoutePaths.farmerProducts);
        }
        if (state is ProductError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Add New Product',
          showBackButton: true,
          fallbackRoute: RoutePaths.farmerProducts,
        ),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Image picker ─────────────────────────────────────────
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload Product Photo',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const Text(
                                'Tap to select from gallery',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Product name ────────────────────────────────────────
                CustomTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g. Ripe Avocado',
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Product name is required'
                          : null,
                ),
                const SizedBox(height: 16),

                // ── Category dropdown ──────────────────────────────────
                if (_isLoadingCategories)
                  const LinearProgressIndicator()
                else if (_categories.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ProductCategory>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        validator: (_) => _selectedCategory == null
                            ? 'Select a category'
                            : null,
                      ),
                    ],
                  )
                else
                  CustomTextField(
                    controller: TextEditingController() // read‑only fallback
                      ..text = 'No categories available',
                    label: 'Category',
                    hint: 'Unavailable',
                    enabled: false,
                  ),
                const SizedBox(height: 16),

                // ── Price & Unit ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _priceController,
                        label: 'Price (KES)',
                        hint: '250',
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Price is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UnitDropdown(
                        value: _selectedUnit,
                        items: _units,
                        onChanged: (v) => setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Quantity ────────────────────────────────────────────
                CustomTextField(
                  controller: _quantityController,
                  label: 'Available Quantity',
                  hint: 'e.g. 100',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Quantity is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Harvest date ────────────────────────────────────────
                GestureDetector(
                  onTap: _selectHarvestDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Harvest Date',
                        hintText: _harvestDate.toLocal().toString().split(' ').first,
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description ──────────────────────────────────────────
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'Describe freshness, quality, etc.',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // ── Active toggle ──────────────────────────────────────
                SwitchListTile(
                  title: const Text('Active listing'),
                  subtitle: const Text('Allow buyers to see this product'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),

                // ── Submit button ──────────────────────────────────────
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    final isLoading = state is ProductLoading;
                    return CustomButton(
                      label: isLoading ? 'Listing...' : 'List Product',
                      isLoading: isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable unit dropdown ──────────────────────────────────────────
class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: items
                .map((i) => DropdownMenuItem(
                      value: i,
                      child: Text(i, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      );
}