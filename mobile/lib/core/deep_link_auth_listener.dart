import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../config/routes.dart';

/// Post-login deep link handler
/// Monitors auth state changes and navigates to stored deep links after successful authentication
class DeepLinkAuthListener extends StatefulWidget {
  final Widget child;
  final AppRouter appRouter;

  const DeepLinkAuthListener({
    super.key,
    required this.child,
    required this.appRouter,
  });

  @override
  State<DeepLinkAuthListener> createState() => _DeepLinkAuthListenerState();
}

class _DeepLinkAuthListenerState extends State<DeepLinkAuthListener> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only listen for successful authentication transitions
        return previous is! AuthAuthenticated && current is AuthAuthenticated;
      },
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _handlePostLoginDeepLink(state.role);
        }
      },
      child: widget.child,
    );
  }

  void _handlePostLoginDeepLink(String role) {
    final storedDeepLink = widget.appRouter.getStoredDeepLink();

    if (storedDeepLink != null) {
      final routePath = storedDeepLink.toRoutePath();
      if (routePath != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            debugPrint('[DeepLinkAuthListener] Navigating to post-login deep link: $routePath');
            widget.appRouter.router.go(routePath);
            widget.appRouter.clearStoredDeepLink();
          }
        });
      }
    }
  }
}
