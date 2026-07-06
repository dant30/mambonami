// mobile/lib/features/auth/pages/splash_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  final Future<void> _minimumDisplay =
      Future<void>.delayed(const Duration(milliseconds: 1500));
  bool _handled = false;
  int _activeDot = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();

    // ─── Animations ────────────────────────────────────────────────
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fade = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    // ─── Animated dots ─────────────────────────────────────────────
    _dotTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      setState(() => _activeDot = (_activeDot + 1) % 3);
    });

    // ─── Auth check ────────────────────────────────────────────────
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _finish(context.read<AuthBloc>().state);
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  /// Navigate to the correct screen after auth state is resolved.
  Future<void> _finish(AuthState state) async {
    if (_handled) return;
    // Wait for a definitive auth state (not loading/initial)
    if (state is! AuthAuthenticated &&
        state is! AuthUnauthenticated &&
        state is! AuthError) {
      return;
    }

    _handled = true;
    await _minimumDisplay;
    if (!mounted) return;

    if (state is AuthAuthenticated) {
      context.go(AppRole.homePathFor(state.role));
    } else {
      context.go(RoutePaths.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _finish(state),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary, // #1B7F3B
                AppColors.secondary, // #2FA84F
                Color(0xFF3DC76A), // light green (matches prototype)
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ─── Decorative circles (prototype) ────────────────────
                Positioned(
                  top: 64,
                  right: 32,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 96,
                  left: 16,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),

                // ─── Centered animated content ──────────────────────────
                Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo container
                            Container(
                              width: 112,
                              height: 112,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.extraExtraLarge,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 30,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // App name
                            Text(
                              'MAMBONAMI',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tagline
                            Text(
                              'Fresh from farm to your door',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.84),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Animated dots
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (index) {
                                final active = index == _activeDot;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: active ? 20 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}