// mobile/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/auth_guard.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_init_page.dart';
import '../features/auth/pages/register_verify_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/buyer/pages/buyer_dashboard.dart';
import '../features/farmer/pages/farmer_dashboard.dart';
import '../features/transport/pages/provider_dashboard.dart';
import '../features/notifications/pages/notifications_page.dart';
import '../features/buyer/pages/order_tracking_page.dart';
import '../features/buyer/pages/order_history_page.dart';
import '../features/buyer/pages/product_catalog_page.dart';
import '../features/buyer/pages/product_detail_page.dart';
import '../features/buyer/pages/cart_page.dart';
import '../features/buyer/pages/checkout_page.dart';
import '../features/buyer/pages/dispute_page.dart';
import '../data/models/product.dart';
import '../features/common/profile_page.dart';
import '../features/common/settings_page.dart';
import '../features/common/support_page.dart';
import '../blocs/auth/auth_bloc.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final role = authState.role;
        if (state.uri.path.startsWith('/$role')) return null;
        if (state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path.startsWith('/register/')) {
          return '/$role';
        }
        return null;
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
      GoRoute(
        path: '/register/verify',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String> && extra.containsKey('phone') && extra.containsKey('role')) {
            return RegisterVerifyPage(phone: extra['phone']!, role: extra['role']!);
          }
          return const Scaffold(body: Center(child: Text('Missing registration data.')));
        },
      ),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: '/buyer',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: BuyerDashboard(),
        ),
      ),
      GoRoute(
        path: '/farmer',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['farmer'],
          child: FarmerDashboard(),
        ),
      ),
      GoRoute(
        path: '/transport_provider',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['transport_provider'],
          child: ProviderDashboard(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer', 'farmer', 'transport_provider'],
          child: NotificationsPage(),
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: OrderHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/products',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: ProductCatalogPage(),
        ),
      ),
      GoRoute(
        path: '/product/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null) return const Scaffold(body: Center(child: Text('Missing product id')));
          return AuthGuard(
            allowedRoles: ['buyer', 'retailer'],
            child: ProductDetailPage(productUuid: uuid, initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: CartPage(),
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: CheckoutPage(),
        ),
      ),
      GoRoute(
        path: '/dispute',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer'],
          child: DisputePage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer', 'farmer', 'transport_provider'],
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer', 'farmer', 'transport_provider'],
          child: SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/support',
        builder: (_, __) => const AuthGuard(
          allowedRoles: ['buyer', 'retailer', 'farmer', 'transport_provider'],
          child: SupportPage(),
        ),
      ),
      GoRoute(
        path: '/order/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null) return const Scaffold(body: Center(child: Text('Missing order id')));
          return AuthGuard(
            allowedRoles: ['buyer', 'retailer', 'farmer', 'transport_provider'],
            child: OrderTrackingPage(orderUuid: uuid),
          );
        },
      ),
    ],
  );
}
