// mobile/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/auth_guard.dart';
import '../core/deep_link_handler.dart';
import 'route_paths.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/welcome_page.dart';
import '../features/auth/pages/otp_page.dart';
import '../features/auth/pages/role_select_page.dart';
import '../features/auth/pages/success_page.dart';
import '../features/auth/pages/buyer_register.dart';
import '../features/auth/pages/farmer_register_page.dart';
import '../features/auth/pages/retailer_register_page.dart';
import '../features/auth/pages/transport_register_page.dart';
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
import '../features/buyer/pages/wishlist_page.dart';
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
import '../features/profile/profile_page.dart';
import '../features/common/settings_page.dart' as settings_page;
import '../features/common/support_page.dart' as support_page;
import '../features/common/terms_and_conditions_page.dart';
import '../features/common/privacy_policy_page.dart';
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
                onPressed: () => context.go(AppRole.homePathFor(context
                        .read<AuthBloc>()
                        .state is AuthAuthenticated
                    ? (context.read<AuthBloc>().state as AuthAuthenticated).role
                    : null)),
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
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => _handleDeepLinksAndAuth(context, state),
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
          path: RoutePaths.welcome, builder: (_, __) => const WelcomePage()),
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: RoutePaths.otp,
        builder: (context, state) {
          final extra = state.extra;
          String? phone;
          String? mode;
          Map<String, dynamic>? data;

          if (extra is Map<String, dynamic>) {
            phone = extra['phone']?.toString();
            mode = extra['mode']?.toString();
            if (extra['dto'] is Map<String, dynamic>) {
              data = extra['dto'] as Map<String, dynamic>;
            } else {
              data = extra;
            }
          } else if (extra is String) {
            phone = extra;
          }

          return OtpPage(phone: phone ?? 'your phone', mode: mode, data: data);
        },
      ),
      GoRoute(
          path: RoutePaths.roleSelect,
          builder: (_, __) => const RoleSelectPage()),
      GoRoute(
        path: RoutePaths.success,
        builder: (context, state) {
          final extra = state.extra;
          final role =
              extra is Map<String, dynamic> ? extra['role'] as String? : null;
          return SuccessPage(role: role);
        },
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, __) => const RoleSelectPage(),
      ),
      GoRoute(
        path: RoutePaths.registerFarmer,
        builder: (_, __) => const FarmerRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerBuyer,
        builder: (_, __) => const BuyerRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerTransport,
        builder: (_, __) => const TransportRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerRetailer,
        builder: (_, __) => const RetailerRegisterPage(),
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
          if (uuid == null) {
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          }
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
          child: FarmerEarningsPage(),
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
        path: RoutePaths.orderHistory,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: OrderHistoryPage(),
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
        path: RoutePaths.productCatalog,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: ProductCatalogPage(),
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
        path: RoutePaths.wishlist,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: WishlistPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null) {
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          }
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
          child: settings_page.SettingsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.support,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: support_page.SupportPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.termsAndConditions,
        builder: (_, __) => const TermsAndConditionsPage(),
      ),
      GoRoute(
        path: RoutePaths.privacyPolicy,
        builder: (_, __) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: RoutePaths.orderTracking,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null) {
            return const Scaffold(
                body: Center(child: Text('Missing order id')));
          }
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
          if (uuid == null) {
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          }
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
          if (uuid == null) {
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          }
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
          if (uuid == null) {
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          }
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
    final path = state.uri.path;
    final isPublicAuthRoute = path == RoutePaths.splash ||
        path == RoutePaths.welcome ||
        path == RoutePaths.login ||
        path == RoutePaths.otp ||
        path == RoutePaths.roleSelect ||
        path == RoutePaths.success ||
        path == RoutePaths.register ||
        path == RoutePaths.forgotPassword ||
        path.startsWith('${RoutePaths.register}/');

    if (path == RoutePaths.splash) {
      if (authState is AuthAuthenticated) {
        return AppRole.homePathFor(authState.role);
      }
      return null;
    }

    if (isPublicAuthRoute) {
      if (authState is AuthAuthenticated &&
          (path == RoutePaths.welcome ||
              path == RoutePaths.login ||
              path == RoutePaths.otp ||
              path == RoutePaths.roleSelect ||
              path == RoutePaths.register ||
              path == RoutePaths.forgotPassword ||
              path.startsWith('${RoutePaths.register}/'))) {
        return AppRole.homePathFor(authState.role);
      }
      return null;
    }

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
        RoutePaths.splash,
        RoutePaths.welcome,
        RoutePaths.otp,
        RoutePaths.roleSelect,
        RoutePaths.success,
        RoutePaths.register,
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
        RoutePaths.orderHistory,
        RoutePaths.orders,
        RoutePaths.productCatalog,
        RoutePaths.products,
        RoutePaths.cart,
        RoutePaths.checkout,
        RoutePaths.dispute,
        RoutePaths.profile,
        RoutePaths.settings,
        RoutePaths.support,
        RoutePaths.wishlist,
      };

      if (path == RoutePaths.splash) return AppRole.homePathFor(role);
      if (AppRole.isHomePathForRole(path, role)) return null;
      if (path == RoutePaths.login ||
          path == RoutePaths.welcome ||
          path == RoutePaths.otp ||
          path == RoutePaths.roleSelect ||
          path == RoutePaths.register ||
          path == RoutePaths.forgotPassword ||
          path.startsWith('${RoutePaths.register}/')) {
        return AppRole.homePathFor(role);
      }
      if (!knownRoutes.contains(path) &&
          !path.startsWith(
              RoutePaths.productDetail.replaceAll(':uuid', '')) &&
          !path.startsWith(
              RoutePaths.orderTracking.replaceAll(':uuid', '')) &&
          !path
              .startsWith(RoutePaths.tripDetail.replaceAll(':uuid', '')) &&
          !path.startsWith(RoutePaths.pickup.replaceAll(':uuid', '')) &&
          !path.startsWith(RoutePaths.delivery.replaceAll(':uuid', '')) &&
          !path.startsWith(
              RoutePaths.farmerProductEdit.replaceAll(':uuid', '')) &&
          !path.startsWith(
              RoutePaths.farmerOrderRequestDetail.replaceAll(':id', ''))) {
        return '/404';
      }
      return null;
    } else if (authState is AuthUnauthenticated) {
      if (isPublicAuthRoute) {
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
