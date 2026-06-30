import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/models/address.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';

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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select Address',
        showBackButton: true,
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: _addressRepository.addresses,
        builder: (context, addresses, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (addresses.isEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'No saved addresses yet. Add one to continue.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
                Expanded(
                  child: ListView.separated(
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Theme.of(context).colorScheme.surfaceVariant,
                        title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(address.detailedAddress),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeAddress(address.id),
                        ),
                        onTap: () => Navigator.of(context).pop(address),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Add New Address',
                  onPressed: _showAddAddressDialog,
                ),
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Address removed.'),
      duration: Duration(seconds: 2),
    ));
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
                  TextFormField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Label (e.g. Home)'),
                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a label' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Street address'),
                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a street' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a city' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: postalCodeController,
                    decoration: const InputDecoration(labelText: 'Postal code'),
                    validator: (value) => value?.trim().isEmpty == true ? 'Enter a postal code' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: landmarkController,
                    decoration: const InputDecoration(labelText: 'Landmark (optional)'),
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
