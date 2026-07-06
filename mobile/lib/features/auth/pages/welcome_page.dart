// lib/features/auth/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Column(
        children: [
          // ─── Gradient Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 44),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.secondaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldAccent.withOpacity(0.08),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadius.large,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset('assets/icons/logo.png'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MAMBONAMI',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Fresh from farm to your door',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Hero image
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.xxlRadius,
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=200&fit=crop&auto=format&q=80',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.2),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.2),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white60,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: -20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.mdRadius,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '12,400+ Verified Farmers',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        'across Kenya',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ─── Content Section ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Column(
                children: [
                  Text(
                    "Kenya's #1 Farm\nMarketplace",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.foregroundDark : AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Direct from farmers. Fair prices. Fresh produce.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.foregroundDark.withOpacity(0.7) : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RoleIcon(asset: 'assets/icons/farmer_icon.png', label: 'Farmer'),
                      _RoleIcon(asset: 'assets/icons/buyer_icon.png', label: 'Buyer'),
                      _RoleIcon(asset: 'assets/icons/transport_icon.png', label: 'Transport'),
                      _RoleIcon(asset: 'assets/icons/secure_payment_icon.png', label: 'Secure Pay'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ─── Get Started (→ login) ──────────────────────────────
                  CustomButton(
                    label: 'Get Started',
                    onPressed: () => context.go(RoutePaths.login),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'I have an account — Log in',
                    onPressed: () => context.go(RoutePaths.login),
                    outlined: true,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By continuing you agree to our ',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.foregroundDark.withOpacity(0.6) : AppColors.textMuted,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms & Privacy Policy',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleIcon extends StatelessWidget {
  final String asset;
  final String label;
  const _RoleIcon({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgRadius,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(asset),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}