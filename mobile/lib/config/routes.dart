// mobile/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/auth_guard.dart';
import '../core/deep_link_handler.dart';
import 'route_paths.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_init_page.dart';
import '../features/auth/pages/register_verify_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/buyer/pages/buyer_dashboard.dart';
import '../features/farmer/pages/farmer_dashboard.dart';
import '../features/transport/pages/provider_dashboard.dart';
import '../features/transport/pages/available_orders_page.dart';
import '../features/transport/pages/my_trips_page.dart';
import '../features/transport/pages/trip_detail_page.dart';
import '../features/transport/pages/pickup_page.dart';
import '../features/transport/pages/delivery_page.dart';
import '../features/transport/pages/earnings_page.dart';
import '../features/notifications/pages/notifications_page.dart';
import '../features/buyer/pages/order_tracking_page.dart';
import '../features/buyer/pages/order_history_page.dart';
import '../features/buyer/pages/product_catalog_page.dart';
import '../features/buyer/pages/product_detail_page.dart';
import '../features/buyer/pages/cart_page.dart';
import '../features/buyer/pages/checkout_page.dart';
import '../features/buyer/pages/address_picker_page.dart';
import '../features/buyer/pages/order_confirmation_page.dart';
import '../features/buyer/pages/dispute_page.dart';
import '../data/models/product.dart';
import '../data/models/order.dart';
import '../features/farmer/pages/product_list_page.dart';
import '../features/farmer/pages/product_create_page.dart';
import '../features/farmer/pages/product_edit_page.dart';
import '../features/farmer/pages/order_requests_page.dart';
import '../features/farmer/pages/order_detail_page.dart';
import '../features/farmer/pages/earnings_page.dart';
import '../features/common/profile_page.dart';
import '../features/common/settings_page.dart';
import '../features/common/support_page.dart';
import '../blocs/auth/auth_bloc.dart';
import 'role_routes.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_rounded, size: 64),
              const SizedBox(height: 12),
              Text(
                'We could not find that page.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please return to the home screen and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(AppRole.homePathFor(context.read<AuthBloc>().state is AuthAuthenticated ? (context.read<AuthBloc>().state as AuthAuthenticated).role : null)),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.login,
    redirect: (context, state) => _handleDeepLinksAndAuth(context, state),
    routes: [
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginPage()),
      GoRoute(
          path: RoutePaths.register,
          builder: (_, __) => const RegisterInitPage()),
      GoRoute(
        path: RoutePaths.registerVerify,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, String> &&
              extra.containsKey('phone') &&
              extra.containsKey('role')) {
            return RegisterVerifyPage(
                phone: extra['phone']!, role: extra['role']!);
          }
          return const Scaffold(
              body: Center(child: Text('Missing registration data.')));
        },
      ),
      GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: RoutePaths.buyerDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: BuyerDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: FarmerDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProducts,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: ProductListPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProductCreate,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: ProductCreatePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProductEdit,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          return AuthGuard(
            allowedRoles: AppRole.farmerRoles,
            child: ProductEditPage(productUuid: uuid, initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.farmerOrderRequests,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: OrderRequestsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerEarnings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: EarningsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerOrderRequestDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final extra = state.extra;
          SubOrder? subOrder;
          if (extra is SubOrder) subOrder = extra;
          if (id == null) {
            return const Scaffold(
                body: Center(child: Text('Missing order request id')));
          }
          final subOrderId = int.tryParse(id);
          if (subOrderId == null) {
            return const Scaffold(
                body: Center(child: Text('Invalid order request id')));
          }
          return AuthGuard(
            allowedRoles: AppRole.farmerRoles,
            child: OrderDetailPage(
                subOrderId: subOrderId, initialSubOrder: subOrder),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.transportProviderDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: ProviderDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: NotificationsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orders,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: OrderHistoryPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.products,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: ProductCatalogPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          return AuthGuard(
            allowedRoles: AppRole.buyerRoles,
            child:
                ProductDetailPage(productUuid: uuid, initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.cart,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: CartPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.addressPicker,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: AddressPickerPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: CheckoutPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderConfirmation,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null) {
            return const Scaffold(
                body: Center(child: Text('Missing order id')));
          }
          return AuthGuard(
            allowedRoles: AppRole.buyerRoles,
            child: OrderConfirmationPage(orderUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.dispute,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: DisputePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: SettingsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.support,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: SupportPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderTracking,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing order id')));
          return AuthGuard(
            allowedRoles: AppRole.operationalRoles,
            child: OrderTrackingPage(orderUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.availableOrders,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: AvailableOrdersPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.myTrips,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: MyTripsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.tripDetail,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: TripDetailPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.pickup,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: PickupPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.delivery,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: DeliveryPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.transportEarnings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: TransportEarningsPage(),
        ),
      ),
      GoRoute(
        path: '/404',
        builder: (_, __) => const NotFoundPage(),
      ),
    ],
    errorBuilder: (_, __) => const NotFoundPage(),
  );

  /// Handle deep links and authentication redirects
  /// Deep links are parsed from incoming URIs (from notifications, app links, etc.)
  /// and routed appropriately based on user authentication state and deep link type
  String? _handleDeepLinksAndAuth(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;

    // First, try to parse deep link from the incoming URI
    final deepLinkInfo = DeepLinkHandler.parseUri(state.uri);
    if (deepLinkInfo.type != DeepLinkType.unknown) {
      // User must be authenticated to access deep-linked content
      if (authState is AuthAuthenticated) {
        final routePath = deepLinkInfo.toRoutePath();
        if (routePath != null) {
          debugPrint('[AppRouter] Deep link redirect to: $routePath');
          return routePath;
        }
      } else if (authState is AuthUnauthenticated) {
        // Not authenticated; store deep link and redirect to login
        _storedDeepLink = deepLinkInfo;
        debugPrint('[AppRouter] Stored deep link for post-login redirect');
        return RoutePaths.login;
      }
    }

    // Standard authentication redirects
    if (authState is AuthAuthenticated) {
      final role = authState.role;
      const knownRoutes = <String>{
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.registerVerify,
        RoutePaths.forgotPassword,
        RoutePaths.buyerDashboard,
        RoutePaths.farmerDashboard,
        RoutePaths.transportProviderDashboard,
        RoutePaths.availableOrders,
        RoutePaths.myTrips,
        RoutePaths.transportEarnings,
        RoutePaths.farmerProducts,
        RoutePaths.farmerProductCreate,
        RoutePaths.farmerOrderRequests,
        RoutePaths.farmerEarnings,
        RoutePaths.notifications,
        RoutePaths.orders,
        RoutePaths.products,
        RoutePaths.cart,
        RoutePaths.checkout,
        RoutePaths.dispute,
        RoutePaths.profile,
        RoutePaths.settings,
        RoutePaths.support,
      };

      final path = state.uri.path;
      if (AppRole.isHomePathForRole(path, role)) return null;
      if (path == RoutePaths.login ||
          path == RoutePaths.register ||
          path.startsWith('${RoutePaths.register}/')) {
        return AppRole.homePathFor(role);
      }
      if (!knownRoutes.contains(path) &&
          !path.startsWith('${RoutePaths.productDetail.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.orderTracking.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.tripDetail.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.pickup.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.delivery.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.farmerProductEdit.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.farmerOrderRequestDetail.replaceAll(':id', '')}')) {
        return '/404';
      }
      return null;
    } else if (authState is AuthUnauthenticated) {
      if (state.uri.path == RoutePaths.login ||
          state.uri.path == RoutePaths.register ||
          state.uri.path.startsWith('${RoutePaths.register}/')) {
        return null;
      }
      return RoutePaths.login;
    }
    return null;
  }

  /// Get stored deep link (used after successful authentication)
  DeepLinkInfo? getStoredDeepLink() {
    return _storedDeepLink;
  }

  /// Clear stored deep link after navigation
  void clearStoredDeepLink() {
    _storedDeepLink = null;
  }

  /// Static variable to store deep link for post-login redirect
  static DeepLinkInfo? _storedDeepLink;
}
