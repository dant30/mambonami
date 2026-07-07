// mobile/lib/features/buyer/pages/address_picker_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../data/models/address.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({super.key});

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  final AddressRepository _addressRepository = GetIt.instance<AddressRepository>();

  @override
  void initState() {
    super.initState();
    _addressRepository.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Address',
        showBackButton: true,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: _addressRepository.addresses,
        builder: (context, addresses, _) {
          return AppScreen(
            scrollable: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                  title: 'Saved addresses',
                  subtitle: 'Choose where your order should be delivered',
                ),
                const SizedBox(height: 8),
                if (addresses.isEmpty) ...[
                  Expanded(
                    child: EmptyState(
                      title: 'No saved addresses',
                      description: 'Add a delivery address to make checkout faster.',
                      icon: Icons.location_on_outlined,
                      buttonText: 'Add address',
                      onButtonPressed: _showAddAddressDialog,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return _AddressTile(
                          address: address,
                          onTap: () => Navigator.of(context).pop(address),
                          onDelete: () => _removeAddress(address.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Add New Address',
                    icon: const Icon(Icons.add_location_alt_outlined),
                    onPressed: _showAddAddressDialog,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeAddress(String addressId) async {
    await _addressRepository.deleteAddress(addressId);
    if (!mounted) return;
    CustomSnackbar.showSuccess(context, 'Address removed.');
  }

  Future<void> _showAddAddressDialog() async {
    final labelController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final postalCodeController = TextEditingController();
    final landmarkController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final savedAddress = await showDialog<Address?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Address'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: labelController,
                    label: 'Label (e.g. Home)',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a label' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: streetController,
                    label: 'Street address',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a street' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: cityController,
                    label: 'City',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a city' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: postalCodeController,
                    label: 'Postal code',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value?.trim().isEmpty == true
                        ? 'Enter a postal code'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: landmarkController,
                    label: 'Landmark (optional)',
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final newAddress = Address(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    label: labelController.text.trim(),
                    street: streetController.text.trim(),
                    city: cityController.text.trim(),
                    postalCode: postalCodeController.text.trim(),
                    landmark: landmarkController.text.trim().isEmpty ? null : landmarkController.text.trim(),
                  );
                  Navigator.of(context).pop(newAddress);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (savedAddress != null) {
      await _addressRepository.saveAddress(savedAddress);
      if (!mounted) return;
      Navigator.of(context).pop(savedAddress);
    }
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: AppRadius.small,
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          address.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          address.detailedAddress,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Delete address',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}