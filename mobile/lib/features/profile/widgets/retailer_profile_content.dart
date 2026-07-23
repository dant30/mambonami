// lib/features/profile/widgets/retailer_profile_content.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/section_header.dart';

class RetailerProfileContent extends StatelessWidget {
  final Map<String, dynamic>? retailerProfile;
  final bool isEditing;
  final TextEditingController? businessNameController;
  final TextEditingController? businessPhoneController;
  final TextEditingController? businessEmailController;
  final TextEditingController? businessAddressController;
  final TextEditingController? businessTypeController;
  final TextEditingController? kraPinController;
  final TextEditingController? businessRegistrationNumberController;
  final TextEditingController? bankAccountController;

  const RetailerProfileContent({
    super.key,
    this.retailerProfile,
    required this.isEditing,
    this.businessNameController,
    this.businessPhoneController,
    this.businessEmailController,
    this.businessAddressController,
    this.businessTypeController,
    this.kraPinController,
    this.businessRegistrationNumberController,
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
              'Retailer Profile',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            _readOnlyRow('Business Name', retailerProfile?['business_name'] ?? 'Not set'),
            _readOnlyRow('Phone', retailerProfile?['business_phone'] ?? 'Not set'),
            _readOnlyRow('Email', retailerProfile?['business_email'] ?? 'Not set'),
            _readOnlyRow('Address', retailerProfile?['business_address'] ?? 'Not set'),
            _readOnlyRow('Type', retailerProfile?['business_type'] ?? 'Not set'),
            _readOnlyRow('KRA PIN', retailerProfile?['kra_pin'] ?? 'Not set'),
            _readOnlyRow('Registration #', retailerProfile?['business_registration_number'] ?? 'Not set'),
            _readOnlyRow('Bank Account', retailerProfile?['bank_account'] ?? 'Not set'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SectionHeader(title: 'Retailer Info', padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessNameController ?? TextEditingController(),
          label: 'Business Name',
          hint: 'e.g. Fresh Foods LTD',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessPhoneController ?? TextEditingController(),
          label: 'Business Phone',
          hint: 'e.g. +254 7XX XXX XXX',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessEmailController ?? TextEditingController(),
          label: 'Business Email',
          hint: 'e.g. contact@business.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessAddressController ?? TextEditingController(),
          label: 'Business Address',
          hint: 'e.g. Nairobi CBD',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessTypeController ?? TextEditingController(),
          label: 'Business Type',
          hint: 'e.g. Grocery, Restaurant',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: kraPinController ?? TextEditingController(),
          label: 'KRA PIN',
          hint: 'e.g. A123456789B',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: businessRegistrationNumberController ?? TextEditingController(),
          label: 'Business Registration Number',
          hint: 'e.g. PVT123456',
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
            width: 120,
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
