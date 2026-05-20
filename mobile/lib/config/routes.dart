// Named routes
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_init_page.dart';
import '../features/auth/pages/register_verify_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/buyer/pages/buyer_dashboard.dart';
import '../features/farmer/pages/farmer_dashboard.dart';
import '../features/transport/pages/provider_dashboard.dart';
import '../features/notifications/pages/notifications_page.dart';
import '../blocs/auth/auth_bloc.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final role = authState.role;
        if (state.uri.path.startsWith('/$role')) return null;
        return '/$role';
      } else if (authState is AuthUnauthenticated) {
        if (state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path.startsWith('/register/')) {
          return null;
        }
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterInitPage()),
      GoRoute(path: '/register/verify', builder: (_, __) => const RegisterVerifyPage()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: '/buyer', builder: (_, __) => const BuyerDashboard()),
      GoRoute(path: '/farmer', builder: (_, __) => const FarmerDashboard()),
      GoRoute(path: '/transport_provider', builder: (_, __) => const ProviderDashboard()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
    ],
  );
}