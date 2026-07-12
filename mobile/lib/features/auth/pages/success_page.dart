// lib/features/auth/pages/success_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';

class SuccessPage extends StatefulWidget {
  final String? role;

  const SuccessPage({super.key, this.role});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final role = widget.role ??
        (authState is AuthAuthenticated ? authState.role : null);
    final roleLabel = AppRole.displayLabel(role).toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Animated checkmark ────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.40),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Gold divider (matches React prototype) ──────────────
              Container(
                width: 64,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Title ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Account Created! 🎉',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ─── Subtitle ──────────────────────────────────────────────
              Text(
                'Welcome to the MAMBONAMI family. Your $roleLabel account is ready.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // ─── Fresh produce image ──────────────────────────────────
              ClipRRect(
                borderRadius: AppRadius.xxl,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=300&h=180&fit=crop&auto=format',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.surfaceHighLight,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.surfaceHighLight,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/icons/secure_payment_icon.png',
                      height: 112,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Dashboard button ──────────────────────────────────────
              CustomButton(
                onPressed: () => context.go(_dashboardPath(role)),
                label: 'Go to Dashboard →',
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the correct dashboard path based on the user's role.
  String _dashboardPath(String? role) {
    switch (role) {
      case 'farmer':
        return RoutePaths.farmerDashboard;
      case 'buyer':
        return RoutePaths.buyerDashboard;
      case 'transport':
      case 'transport_provider':
        return RoutePaths.transportProviderDashboard;
      case 'retailer':
        return RoutePaths.buyerDashboard; // Retailer uses buyer dashboard
      default:
        return RoutePaths.buyerDashboard;
    }
  }
}