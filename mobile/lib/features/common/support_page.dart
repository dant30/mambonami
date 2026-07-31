// lib/features/common/support_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/route_paths.dart';
import '../../shared/layouts/app_drawer.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/layouts/custom_app_bar.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_gradients.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/section_header.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String _issueType = 'Payment / Escrow';
  final TextEditingController _messageController = TextEditingController();
  bool _submitted = false;
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Payment / Escrow',
    'Order dispute',
    'App bug',
    'Account issue',
    'Other',
  ];

  final List<Map<String, String>> _faq = const [
    {'q': 'How does M-Pesa escrow work?'},
    {'q': 'How do I confirm a delivery with OTP?'},
    {'q': 'What happens if a farmer cancels my order?'},
    {'q': 'How long do payouts take?'},
    {'q': 'How do I become a verified farmer?'},
    {'q': 'What vehicles are accepted for transport?'},
  ];

  final List<Map<String, dynamic>> _contactChannels = const [
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

  Future<void> _submitTicket() async {
    if (_messageController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please describe your issue');
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
      _messageController.clear();
    });

    CustomSnackbar.showSuccess(context, 'Ticket submitted successfully!');
  }

  @override
  void dispose() {
    _messageController.dispose();
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
              decoration: BoxDecoration(gradient: AppGradients.hero),
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
                        return _ContactCard(
                          emoji: channel['emoji'] as String,
                          label: channel['label'] as String,
                          sub: channel['sub'] as String,
                          onTap: () => _handleContactAction(channel['action'] as String),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ─── FAQ Section ────────────────────────────────────────
                    const SectionHeader(title: 'Frequently Asked Questions'),
                    const SizedBox(height: 8),
                    ..._faq.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomCard(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              item['q']!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.dark,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onTap: () {
                              CustomSnackbar.showInfo(
                                context,
                                'FAQ answer coming soon!',
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Submit Ticket ──────────────────────────────────────
                    CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submit a Ticket',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Our team will respond within 24 hours',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Issue type dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _issueType,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.inputDark
                                  : AppColors.inputLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: _issueTypes.map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _issueType = v ?? _issueType),
                          ),
                          const SizedBox(height: 12),

                          // Message text field
                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your issue in detail...',
                              hintStyle: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.inputDark
                                  : AppColors.inputLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Submit button
                          if (_submitted)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '✓ Ticket submitted!',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            CustomButton(
                              label: _isSubmitting ? 'Submitting...' : 'Submit Ticket',
                              isLoading: _isSubmitting,
                              onPressed: _submitTicket,
                            ),
                        ],
                      ),
                    ),
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

class _ContactCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ContactCard({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onTap,
  });

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