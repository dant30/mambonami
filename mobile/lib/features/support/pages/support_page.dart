// lib/features/common/support_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/contact_card.dart';
import '../widgets/faq_item.dart';
import '../widgets/ticket_form.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final List<String> _faq = const [
    'How does M-Pesa escrow work?',
    'How do I confirm a delivery with OTP?',
    'What happens if a farmer cancels my order?',
    'How long do payouts take?',
    'How do I become a verified farmer?',
    'What vehicles are accepted for transport?',
  ];

  final List<Map<String, String>> _contactChannels = const [
    {'emoji': '💬', 'label': 'Live Chat', 'sub': 'Avg. 2 min reply', 'action': 'chat'},
    {'emoji': '📞', 'label': 'Call Us', 'sub': '+254 700 MAMBA', 'action': 'call'},
    {'emoji': '📧', 'label': 'Email', 'sub': 'support@mambonami.com', 'action': 'email'},
    {'emoji': '🤖', 'label': 'WhatsApp', 'sub': '+254 700 262262', 'action': 'whatsapp'},
  ];

  Future<void> _handleContactAction(String action) async {
    switch (action) {
      case 'call':
        final Uri phoneUri = Uri(scheme: 'tel', path: '+254700MAMBA');
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          CustomSnackbar.showError(context, 'Unable to make call');
        }
        break;
      case 'email':
        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: 'support@mambonami.com',
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          CustomSnackbar.showError(context, 'Unable to open email');
        }
        break;
      case 'whatsapp':
        final Uri whatsappUri = Uri.parse(
          'https://wa.me/254700262262?text=Hi%20MAMBONAMI%20support',
        );
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          CustomSnackbar.showError(context, 'Unable to open WhatsApp');
        }
        break;
      case 'chat':
        CustomSnackbar.showInfo(context, 'Live chat coming soon!');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Help & Support',
        showNotificationAction: false,
        showBackButton: true,
        fallbackRoute: RoutePaths.profile,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Gradient Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(4, 0, 20, 16),
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: Row(
                children: [
                  // Back button is already in CustomAppBar
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Help & Support',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'We\'re here to help you',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Scrollable Body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Contact Channels ─────────────────────────────────
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: _contactChannels.map((channel) {
                        return SupportContactCard(
                          emoji: channel['emoji']!,
                          label: channel['label']!,
                          sub: channel['sub']!,
                          onTap: () => _handleContactAction(channel['action']!),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ─── FAQ Section ────────────────────────────────────────
                    const SectionHeader(title: 'Frequently Asked Questions'),
                    const SizedBox(height: 8),
                    ..._faq.map(
                      (question) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SupportFaqItem(question: question),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SupportTicketForm(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact Card Widget ─────────────────────────────────────────────────────


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}