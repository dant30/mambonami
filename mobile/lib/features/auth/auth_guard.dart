import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String fallbackPath;

  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles = const [],
    this.fallbackPath = '/login',
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState is AuthAuthenticated) {
      if (allowedRoles.isEmpty || allowedRoles.contains(authState.role)) {
        return child;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(fallbackPath);
        }
      });
      return const UnauthorizedPage();
    }

    if (authState is AuthUnauthenticated || authState is AuthInitial || authState is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && GoRouter.of(context).location != fallbackPath) {
          context.go(fallbackPath);
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return child;
  }
}

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Unauthorized'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You do not have permission to access this page.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () => context.go('/login'),
              label: 'Go to Login',
            ),
          ],
        ),
      ),
    );
  }
}
