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
import '../../../shared/utils/image_picker_helper.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _shelfLifeController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _harvestDate = DateTime.now();
  bool _isActive = true;
  File? _selectedImage;
  bool _isLoadingCategories = true;
  List<ProductCategory> _categories = [];
  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _varietyController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _shelfLifeController.dispose();
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

    final categoryId = _selectedCategory?.id ?? int.tryParse(_categoryController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final quantity = double.tryParse(_quantityController.text.trim());
    final shelfLife = int.tryParse(_shelfLifeController.text.trim());

    if (categoryId == null || price == null || quantity == null || shelfLife == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid category, price, quantity, and shelf life values.')),
      );
      return;
    }

    final productData = <String, dynamic>{
      'category': categoryId,
      'name': _nameController.text.trim(),
      'variety': _varietyController.text.trim().isEmpty ? null : _varietyController.text.trim(),
      'price_per_unit': price,
      'available_quantity': quantity,
      'unit': _unitController.text.trim(),
      'harvest_date': _harvestDate.toIso8601String().split('T').first,
      'shelf_life_days': shelfLife,
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'is_active': _isActive,
      if (_selectedImage != null) 'image': _selectedImage,
    };

    context.read<ProductBloc>().add(CreateProductEvent(productData));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${state.product.displayName}" created successfully.')),
          );
          context.go(RoutePaths.farmerProducts);
        }
        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is ProductLoading;
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Create Product',
            showBackButton: true,
            fallbackRoute: RoutePaths.farmerProducts,
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add a new product', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('Fill details and publish to your catalog', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_isLoadingCategories)
                    const LinearProgressIndicator()
                  else if (_categories.isNotEmpty)
                    DropdownButtonFormField<ProductCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged: isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategory = value;
                                _categoryController.text = value?.id.toString() ?? '';
                              });
                            },
                      validator: (_) => _selectedCategory == null ? 'Select a category' : null,
                    )
                  else
                    TextFormField(
                      controller: _categoryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Category ID', hintText: 'Enter backend category ID'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Category is required' : null,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Product name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _varietyController,
                    decoration: const InputDecoration(labelText: 'Variety (optional)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Price per unit'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Price is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Available quantity'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Quantity is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit (e.g. kg, crate)'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Unit is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shelfLifeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Shelf life (days)'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Shelf life is required' : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isSaving ? null : _selectHarvestDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Harvest date',
                          hintText: _harvestDate.toLocal().toString().split(' ').first,
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                        validator: (_) => null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 16),
                  Text('Product photo', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : _pickImage,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Upload image'),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                    )
                  else
                    Text(
                      'No image selected yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active listing'),
                    subtitle: const Text('Allow buyers to see this product'),
                    value: _isActive,
                    onChanged: isSaving ? null : (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                      : const Text('Create product'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
