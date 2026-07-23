// lib/features/profile/widgets/buyer_profile_content.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/section_header.dart';

class BuyerProfileContent extends StatelessWidget {
  final Map<String, dynamic>? buyerProfile;
  final bool isEditing;
  final TextEditingController? deliveryAddressController;
  final TextEditingController? deliveryInstructionsController;
  final TextEditingController? bankAccountController;

  const BuyerProfileContent({
    super.key,
    this.buyerProfile,
    required this.isEditing,
    this.deliveryAddressController,
    this.deliveryInstructionsController,
    this.bankAccountController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buyer Profile',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            _readOnlyRow('Delivery Address', buyerProfile?['delivery_address'] ?? 'Not set'),
            _readOnlyRow('Delivery Instructions', buyerProfile?['delivery_instructions'] ?? 'Not set'),
            _readOnlyRow('Bank Account', buyerProfile?['bank_account'] ?? 'Not set'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader(title: 'Buyer Info', padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        CustomTextField(
          controller: deliveryAddressController ?? TextEditingController(),
          label: 'Delivery Address',
          hint: 'e.g. 123 Nairobi Street',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: deliveryInstructionsController ?? TextEditingController(),
          label: 'Delivery Instructions',
          hint: 'e.g. Leave at the gate',
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: bankAccountController ?? TextEditingController(),
          label: 'Bank Account',
          hint: 'e.g. 1234567890',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}
