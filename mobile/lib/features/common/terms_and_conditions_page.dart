import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'By creating an account on Mambonami, you agree to use the platform responsibly and provide accurate information. You are responsible for safeguarding your login credentials and ensuring that all listings, orders, payments, and messages you share comply with applicable laws and platform rules.',
            ),
            const SizedBox(height: 16),
            const Text(
              'You agree not to misuse the marketplace, submit fraudulent payments or false claims, or interfere with other users or platform operations. Mambonami may suspend or remove accounts that violate these rules or create safety risks.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Payments, delivery arrangements, and disputes are governed by the platform policies and applicable Kenyan law. We may update these terms from time to time and will publish changes through the app.',
            ),
            const SizedBox(height: 24),
            Text(
              'Contact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Email: hello@mambonami.com'),
            const Text('Phone: +254 728 102 107'),
          ],
        ),
      ),
    );
  }
}
