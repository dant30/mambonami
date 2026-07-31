import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mambonami collects account details, contact information, location data, payment references, licensing information, and usage data needed to operate the marketplace and logistics platform.',
            ),
            const SizedBox(height: 12),
            const Text(
              'We use this information to facilitate transactions, verify identities, coordinate deliveries, send notifications, improve services, and comply with legal obligations. We do not sell personal data to third parties.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Information may be shared with payment processors, messaging providers, cloud hosting providers, and regulators where necessary. You can request access, correction, or deletion of your data by contacting privacy@mambonami.com.',
            ),
            const SizedBox(height: 24),
            Text(
              'Last updated',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text('May 2026'),
          ],
        ),
      ),
    );
  }
}
