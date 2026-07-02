# MAMBONAMI — Flutter Screen Specifications (v2.0)
**Updated:** July 2026 | **Stack:** Flutter 3.x · Dart 3.x · BLoC · Material Design 3  
**Font:** Poppins (assets/fonts/Poppins.ttf or google_fonts)  
**Architecture:** Feature-based BLoC — see `mobile_file_structure.txt`

> **Visual reference:** The React prototype in `mambonami/web` shows all screens interactively.  
> Navigate it at full fidelity as a design spec before implementing each screen.

---

## Screen Inventory (33 Screens)

| # | Screen | File | Role |
|---|--------|------|------|
| 1 | Splash | `lib/features/auth/pages/splash_page.dart` | All |
| 2 | Welcome | `lib/features/auth/pages/welcome_page.dart` | All |
| 3 | Login | `lib/features/auth/pages/login_page.dart` | All |
| 4 | Forgot Password | `lib/features/auth/pages/forgot_password_page.dart` | All |
| 5 | OTP Verification | `lib/features/auth/pages/register_verify_page.dart` | All |
| 6 | Role Selection | `lib/features/auth/pages/register_init_page.dart` | All |
| 7 | Farmer Registration | `lib/features/auth/pages/register_init_page.dart` | Farmer |
| 8 | Buyer Registration | `lib/features/auth/pages/register_init_page.dart` | Buyer |
| 9 | Transport Registration | `lib/features/auth/pages/register_init_page.dart` | Transport |
| 10 | Retailer Registration | `lib/features/auth/pages/register_init_page.dart` | Retailer |
| 11 | Success | `lib/features/auth/pages/register_verify_page.dart` | All |
| 12 | Farmer Dashboard | `lib/features/farmer/pages/farmer_dashboard.dart` | Farmer |
| 13 | Product List | `lib/features/farmer/pages/product_list_page.dart` | Farmer |
| 14 | Add Product | `lib/features/farmer/pages/product_create_page.dart` | Farmer |
| 15 | Order Requests | `lib/features/farmer/pages/order_requests_page.dart` | Farmer |
| 16 | Order Detail (Farmer) | `lib/features/farmer/pages/order_detail_page.dart` | Farmer |
| 17 | Earnings & Wallet | `lib/features/farmer/pages/earnings_page.dart` | Farmer |
| 18 | Buyer Dashboard | `lib/features/buyer/pages/buyer_dashboard.dart` | Buyer |
| 19 | Product Catalog | `lib/features/buyer/pages/product_catalog_page.dart` | Buyer |
| 20 | Product Detail | `lib/features/buyer/pages/product_detail_page.dart` | Buyer |
| 21 | Cart | `lib/features/buyer/pages/cart_page.dart` | Buyer |
| 22 | M-Pesa Checkout | `lib/features/buyer/pages/checkout_page.dart` | Buyer |
| 23 | Order Tracking | `lib/features/buyer/pages/order_tracking_page.dart` | Buyer |
| 24 | Order History | `lib/features/buyer/pages/order_history_page.dart` | Buyer |
| 25 | Transport Dashboard | `lib/features/transport/pages/provider_dashboard.dart` | Transport |
| 26 | Available Orders | `lib/features/transport/pages/available_orders_page.dart` | Transport |
| 27 | Delivery OTP | `lib/features/transport/pages/delivery_page.dart` | Transport |
| 28 | My Trips | `lib/features/transport/pages/my_trips_page.dart` | Transport |
| 29 | Retailer Dashboard | `lib/features/buyer/pages/buyer_dashboard.dart` (retailer variant) | Retailer |
| 30 | Notifications | `lib/features/common/notifications_page.dart` | All |
| 31 | Profile | `lib/features/common/profile_page.dart` | All |
| 32 | Settings | `lib/features/common/settings_page.dart` | All |
| 33 | Help & Support | `lib/features/common/support_page.dart` | All |

---

## Design System

### Colors — `lib/config/theme.dart`
```dart
class AppColors {
  // Primary brand
  static const primaryGreen   = Color(0xFF1B7F3B);
  static const secondaryGreen = Color(0xFF2FA84F);
  static const goldAccent     = Color(0xFFD4AF37);

  // Backgrounds
  static const background     = Color(0xFFF7FAF7);
  static const cardBackground = Color(0xFFFFFFFF);
  static const lightGreen     = Color(0xFFE8F2EB);
  static const inputBackground= Color(0xFFF0F5F1);

  // Text
  static const textDark       = Color(0xFF0F1F15);
  static const textMuted      = Color(0xFF5A7A63);

  // Semantic
  static const success        = Color(0xFF22C55E);
  static const warning        = Color(0xFFF59E0B);
  static const error          = Color(0xFFEF4444);

  // Role accent
  static const transportPurple = Color(0xFF6D28D9);
  static const retailerPurple  = Color(0xFF4C1D95);
}
```

### Assets — `pubspec.yaml`
```yaml
flutter:
  assets:
    - assets/icons/logo.png
    - assets/icons/farmer_icon.png
    - assets/icons/buyer_icon.png
    - assets/icons/transport_icon.png
    - assets/icons/secure_payment_icon.png
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf   weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf     weight: 700
        - asset: assets/fonts/Poppins-ExtraBold.ttf weight: 800
```

### Typography
```dart
// lib/config/theme.dart

TextTheme get textTheme => const TextTheme(
  displayLarge:  TextStyle(fontFamily:'Poppins', fontSize:28, fontWeight:FontWeight.w800, color:AppColors.textDark),
  headlineLarge: TextStyle(fontFamily:'Poppins', fontSize:22, fontWeight:FontWeight.w700, color:AppColors.textDark),
  headlineMedium:TextStyle(fontFamily:'Poppins', fontSize:18, fontWeight:FontWeight.w700, color:AppColors.textDark),
  titleMedium:   TextStyle(fontFamily:'Poppins', fontSize:15, fontWeight:FontWeight.w700, color:AppColors.textDark),
  titleSmall:    TextStyle(fontFamily:'Poppins', fontSize:13, fontWeight:FontWeight.w600, color:AppColors.textDark),
  bodyMedium:    TextStyle(fontFamily:'Poppins', fontSize:13, fontWeight:FontWeight.w400, color:AppColors.textMuted),
  bodySmall:     TextStyle(fontFamily:'Poppins', fontSize:11, fontWeight:FontWeight.w400, color:AppColors.textMuted),
  labelSmall:    TextStyle(fontFamily:'Poppins', fontSize:10, fontWeight:FontWeight.w600, color:AppColors.textMuted),
);
```

### Spacing & Radius
```dart
class AppSpacing {
  static const xs = 4.0;   static const sm = 8.0;
  static const md = 16.0;  static const lg = 24.0;
  static const xl = 32.0;  static const xxl = 48.0;
}

class AppRadius {
  static const sm   = BorderRadius.all(Radius.circular(12));
  static const md   = BorderRadius.all(Radius.circular(16));
  static const lg   = BorderRadius.all(Radius.circular(20));
  static const xl   = BorderRadius.all(Radius.circular(24));
  static const xxl  = BorderRadius.all(Radius.circular(32));
  static const full = BorderRadius.all(Radius.circular(999));
}
```

### Shadows
```dart
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> primary = [
    BoxShadow(color: AppColors.primaryGreen.withOpacity(0.35), blurRadius: 15, offset: Offset(0, 4)),
  ];
}
```

---

## Shared Widgets — `lib/shared/widgets/`

### `custom_button.dart`
```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool outline;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 54),
          side: BorderSide(color: AppColors.primaryGreen, width: 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        ),
        child: Text(label, style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 15)),
      );
    }
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.secondaryGreen, AppColors.primaryGreen]),
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.primary,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
```

### `custom_text_field.dart`
```dart
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
      SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: AppRadius.lg, borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: AppRadius.lg, borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: AppRadius.lg, borderSide: BorderSide(color: AppColors.secondaryGreen, width: 1.5)),
        ),
      ),
    ],
  );
}
```

### `bottom_nav_bar.dart` — Role-based
```dart
// lib/shared/widgets/bottom_nav_bar.dart

class MambonamisBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  List<BottomNavigationBarItem> _itemsForRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.buyer:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.transport:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.navigation_rounded), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
      case UserRole.retailer:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.store_rounded), label: 'Suppliers'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primaryGreen,
    unselectedItemColor: AppColors.textMuted,
    selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 10),
    elevation: 8,
    items: _itemsForRole(role),
  );
}
```

### `empty_state.dart`
```dart
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: TextStyle(fontSize: 56)),
      SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
      if (actionLabel != null) ...[
        SizedBox(height: 24),
        SizedBox(width: 200, child: AppButton(label: actionLabel!, onPressed: onAction!)),
      ]
    ]),
  );
}
```

### `loading_indicator.dart`
```dart
class AppLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 3),
  );
}
```

### OTP Input — `lib/features/auth/widgets/otp_input_field.dart`
```dart
// Uses pinput: ^5.0.0
import 'package:pinput/pinput.dart';

class OtpInputField extends StatelessWidget {
  final void Function(String) onCompleted;

  final defaultTheme = PinTheme(
    width: 64, height: 64,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppRadius.lg,
      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
    ),
    textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
  );

  final focusedTheme = PinTheme(
    width: 64, height: 64,
    decoration: BoxDecoration(
      color: AppColors.lightGreen,
      borderRadius: AppRadius.lg,
      border: Border.all(color: AppColors.primaryGreen, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) => Pinput(
    length: 4,
    defaultPinTheme: defaultTheme,
    focusedPinTheme: focusedTheme,
    submittedPinTheme: focusedTheme,
    keyboardType: TextInputType.number,
    onCompleted: onCompleted,
  );
}
```

---

## Routes — `lib/config/routes.dart`

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    // Check JWT token validity here
    // If token invalid and not on auth pages → redirect to /login
    return null;
  },
  routes: [
    // Auth
    GoRoute(path: '/splash',            builder: (_, __) => SplashPage()),
    GoRoute(path: '/welcome',           builder: (_, __) => WelcomePage()),
    GoRoute(path: '/login',             builder: (_, __) => LoginPage()),
    GoRoute(path: '/forgot-password',   builder: (_, __) => ForgotPasswordPage()),
    GoRoute(path: '/otp',               builder: (_, s) => OtpPage(phone: s.extra as String?)),
    GoRoute(path: '/role-select',       builder: (_, __) => RoleSelectPage()),
    GoRoute(path: '/register/farmer',   builder: (_, __) => FarmerRegisterPage()),
    GoRoute(path: '/register/buyer',    builder: (_, __) => BuyerRegisterPage()),
    GoRoute(path: '/register/transport',builder: (_, __) => TransportRegisterPage()),
    GoRoute(path: '/register/retailer', builder: (_, __) => RetailerRegisterPage()),
    GoRoute(path: '/success',           builder: (_, s) => SuccessPage(role: s.extra as String)),

    // Farmer
    GoRoute(path: '/farmer',            builder: (_, __) => FarmerDashboard()),
    GoRoute(path: '/farmer/products',   builder: (_, __) => ProductListPage()),
    GoRoute(path: '/farmer/products/create', builder: (_, __) => ProductCreatePage()),
    GoRoute(path: '/farmer/products/:id/edit', builder: (_, s) => ProductEditPage(id: s.pathParameters['id']!)),
    GoRoute(path: '/farmer/orders',     builder: (_, __) => OrderRequestsPage()),
    GoRoute(path: '/farmer/orders/:id', builder: (_, s) => FarmerOrderDetailPage(id: s.pathParameters['id']!)),
    GoRoute(path: '/farmer/earnings',   builder: (_, __) => FarmerEarningsPage()),

    // Buyer
    GoRoute(path: '/buyer',             builder: (_, __) => BuyerDashboard()),
    GoRoute(path: '/buyer/catalog',     builder: (_, __) => ProductCatalogPage()),
    GoRoute(path: '/buyer/products/:id',builder: (_, s) => ProductDetailPage(id: s.pathParameters['id']!)),
    GoRoute(path: '/cart',              builder: (_, __) => CartPage()),
    GoRoute(path: '/checkout',          builder: (_, s) => CheckoutPage(orderId: s.extra as String)),
    GoRoute(path: '/buyer/orders',      builder: (_, __) => OrderHistoryPage()),
    GoRoute(path: '/buyer/orders/:id/track', builder: (_, s) => OrderTrackingPage(orderId: s.pathParameters['id']!)),
    GoRoute(path: '/buyer/orders/:id/dispute', builder: (_, s) => DisputePage(orderId: s.pathParameters['id']!)),

    // Transport
    GoRoute(path: '/transport',         builder: (_, __) => TransportDashboard()),
    GoRoute(path: '/transport/available', builder: (_, __) => AvailableOrdersPage()),
    GoRoute(path: '/transport/trips',   builder: (_, __) => MyTripsPage()),
    GoRoute(path: '/transport/trips/:id', builder: (_, s) => TripDetailPage(id: s.pathParameters['id']!)),
    GoRoute(path: '/transport/pickup/:id', builder: (_, s) => PickupPage(orderId: s.pathParameters['id']!)),
    GoRoute(path: '/transport/delivery/:id', builder: (_, s) => DeliveryPage(orderId: s.pathParameters['id']!)),
    GoRoute(path: '/transport/earnings', builder: (_, __) => TransportEarningsPage()),

    // Common
    GoRoute(path: '/notifications',     builder: (_, __) => NotificationsPage()),
    GoRoute(path: '/profile',           builder: (_, __) => ProfilePage()),
    GoRoute(path: '/settings',          builder: (_, __) => SettingsPage()),
    GoRoute(path: '/support',           builder: (_, __) => SupportPage()),
  ],
);
```

---

## BLoC Architecture — `lib/blocs/`

### Auth BLoC

```dart
// lib/blocs/auth/auth_event.dart
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  LoginRequested({required this.phone, required this.password});
}
class OtpVerifyRequested extends AuthEvent { final String otp; ... }
class RegisterRequested extends AuthEvent { final RegisterDto dto; ... }
class LogoutRequested extends AuthEvent {}
class TokenRefreshRequested extends AuthEvent {}

// lib/blocs/auth/auth_state.dart
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState { final User user; ... }
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { final String message; ... }
class OtpSent extends AuthState { final String phone; ... }
class OtpVerified extends AuthState {}
class RegisterSuccess extends AuthState { final User user; ... }

// lib/blocs/auth/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _storage;

  AuthBloc({required AuthRepository authRepository, required SecureStorage storage})
      : _authRepository = authRepository, _storage = storage, super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<OtpVerifyRequested>(_onOtpVerify);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(event.phone, event.password);
      await _storage.saveToken(result.token);
      emit(OtpSent(phone: event.phone)); // If OTP required
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  // ... other handlers
}
```

### Order BLoC
```dart
// lib/blocs/order/order_event.dart
abstract class OrderEvent {}
class FetchOrders extends OrderEvent {}
class ConfirmOrder extends OrderEvent { final String orderId; }
class DeclineOrder extends OrderEvent { final String orderId; final String reason; }
class MarkOrderReady extends OrderEvent { final String orderId; }

// lib/blocs/order/order_state.dart
abstract class OrderState {}
class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrdersLoaded extends OrderState { final List<Order> orders; }
class OrderConfirmed extends OrderState { final Order order; }
class OrderError extends OrderState { final String message; }
```

### Trip BLoC (Transport)
```dart
// lib/blocs/trip/trip_event.dart
abstract class TripEvent {}
class FetchAvailableTrips extends TripEvent {}
class AcceptTrip extends TripEvent { final String orderId; }
class DeclineTrip extends TripEvent { final String orderId; }
class MarkPickedUp extends TripEvent { final String orderId; final File photo; }
class ConfirmDelivery extends TripEvent {
  final String orderId;
  final String otp;
  final File deliveryPhoto;
}

// lib/blocs/trip/trip_state.dart
abstract class TripState {}
class TripInitial extends TripState {}
class TripsLoaded extends TripState { final List<Trip> available; final Trip? current; }
class OtpVerificationSuccess extends TripState {}
class TripError extends TripState { final String message; }
```

---

## Screen 1 — Splash

**File:** `lib/features/auth/pages/splash_page.dart`

```dart
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    _scale = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(Duration(seconds: 3), () => context.go('/welcome'));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen, Color(0xFF3DC76A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 112, height: 112,
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xxl,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10))]),
              padding: EdgeInsets.all(12),
              child: Image.asset('assets/icons/logo.png'),
            ),
            SizedBox(height: 24),
            Text('MAMBONAMI', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
              color: Colors.white, letterSpacing: -0.5)),
            SizedBox(height: 8),
            Text('Fresh from farm to your door', style: TextStyle(fontSize: 14, color: Colors.white70)),
            SizedBox(height: 48),
            // Animated dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Dot(active: true),  SizedBox(width: 6),
              _Dot(active: false), SizedBox(width: 6),
              _Dot(active: false),
            ]),
          ]),
        ),
      )),
    ),
  );
}
```

---

## Screen 2 — Welcome

**File:** `lib/features/auth/pages/welcome_page.dart`

```dart
@override
Widget build(BuildContext context) => Scaffold(
  backgroundColor: AppColors.background,
  body: Column(children: [
    // Hero green section (440px)
    Container(
      height: 440,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryGreen, AppColors.secondaryGreen, Color(0xFF3DC76A)]),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(children: [
          // Decorative circles
          Positioned(top: -40, right: -40, child: _Circle(size: 200, color: Colors.white, opacity: 0.08)),
          Positioned(bottom: -20, left: -20, child: _Circle(size: 140, color: AppColors.goldAccent, opacity: 0.08)),

          // Content
          Padding(padding: EdgeInsets.fromLTRB(24, 16, 24, 24), child: Column(children: [
            // Logo
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lg),
                padding: EdgeInsets.all(8),
                child: Image.asset('assets/icons/logo.png')),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MAMBONAMI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Fresh from farm to your door', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ]),
            ]),
            SizedBox(height: 24),
            // Hero image with floating card
            Stack(alignment: Alignment.bottomLeft, children: [
              ClipRRect(
                borderRadius: AppRadius.xxl,
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=340&h=200&fit=crop',
                  height: 200, width: double.infinity, fit: BoxFit.cover,
                ),
              ),
              Positioned(left: 12, bottom: -20, child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.md,
                  boxShadow: AppShadows.card),
                child: Row(children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('12,400+ Verified Farmers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text('across Kenya', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                  ]),
                ]),
              )),
            ]),
          ])),
        ]),
      ),
    ),

    // Content section
    Expanded(child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Column(children: [
        Text("Kenya's #1 Farm\nMarketplace", textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2)),
        SizedBox(height: 8),
        Text('Direct from farmers. Fair prices. Fresh produce.', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted)),

        // Role icons
        SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _RoleIcon(asset: 'assets/icons/farmer_icon.png', label: 'Farmer'),
          _RoleIcon(asset: 'assets/icons/buyer_icon.png', label: 'Buyer'),
          _RoleIcon(asset: 'assets/icons/transport_icon.png', label: 'Transport'),
          _RoleIcon(asset: 'assets/icons/secure_payment_icon.png', label: 'Secure Pay'),
        ]),

        SizedBox(height: 24),
        AppButton(label: 'Get Started', onPressed: () => context.go('/login')),
        SizedBox(height: 12),
        AppButton(label: 'I have an account — Log in', onPressed: () => context.go('/login'), outline: true),
        SizedBox(height: 16),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'By continuing you agree to our ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          TextSpan(text: 'Terms & Privacy Policy', style: TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
        ])),
      ]),
    )),
  ]),
);
```

---

## Screen 3 — Login

**File:** `lib/features/auth/pages/login_page.dart`

```dart
// BLoC state wiring
@override
Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
  listener: (ctx, state) {
    if (state is OtpSent) ctx.go('/otp', extra: state.phone);
    if (state is AuthError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
  },
  child: Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(icon: Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.go('/welcome')),
        SizedBox(height: 20),
        // Logo + heading
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lg,
            boxShadow: AppShadows.card), padding: EdgeInsets.all(8),
            child: Image.asset('assets/icons/logo.png')),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome back 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Sign in to your account', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ]),
        SizedBox(height: 28),

        // Form
        Form(key: _formKey, child: Column(children: [
          AppTextField(label: 'Phone Number', hint: '+254 700 000 000',
            controller: _phoneCtrl, keyboardType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone_rounded, color: AppColors.textMuted, size: 18)),
          SizedBox(height: 16),
          AppTextField(label: 'Password', hint: 'Enter your password',
            controller: _passCtrl, obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
          SizedBox(height: 8),
          Align(alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => context.go('/forgot-password'),
              child: Text('Forgot password?', style: TextStyle(color: AppColors.secondaryGreen, fontSize: 12, fontWeight: FontWeight.w600)))),
        ])),

        SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(builder: (ctx, state) =>
          AppButton(label: 'Login', isLoading: state is AuthLoading,
            onPressed: () => ctx.read<AuthBloc>().add(LoginRequested(phone: _phoneCtrl.text, password: _passCtrl.text)))),

        // Divider
        Padding(padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(children: [
            Expanded(child: Divider(color: AppColors.primaryGreen.withOpacity(0.15))),
            Padding(padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
            Expanded(child: Divider(color: AppColors.primaryGreen.withOpacity(0.15))),
          ])),

        // Google button
        OutlinedButton.icon(
          onPressed: _signInWithGoogle,
          icon: Image.network('https://www.google.com/favicon.ico', width: 18, height: 18),
          label: Text('Continue with Google', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 52),
            side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
          ),
        ),

        SizedBox(height: 24),
        Center(child: Text.rich(TextSpan(children: [
          TextSpan(text: 'No account? ', style: TextStyle(color: AppColors.textMuted)),
          WidgetSpan(child: GestureDetector(onTap: () => context.go('/role-select'),
            child: Text('Create one', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 14)))),
        ]))),
      ]),
    )),
  ),
);
```

---

## Screen 4 — Forgot Password

**File:** `lib/features/auth/pages/forgot_password_page.dart`

```dart
// Two states: form → sent confirmation
// State: bool _codeSent = false

Widget build(BuildContext context) => Scaffold(
  backgroundColor: AppColors.background,
  body: SafeArea(child: Padding(
    padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      BackButton(),
      SizedBox(height: 24),
      Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: AppRadius.lg),
        child: Icon(Icons.shield_rounded, color: AppColors.primaryGreen, size: 32)),
      SizedBox(height: 16),
      Text('Forgot Password?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      SizedBox(height: 8),
      Text("Enter your registered phone number. We'll send a reset code via SMS.",
        style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      SizedBox(height: 28),

      if (!_codeSent) ...[
        AppTextField(label: 'Phone Number', hint: '+254 700 000 000',
          controller: _phoneCtrl, keyboardType: TextInputType.phone,
          prefixIcon: Icon(Icons.phone_rounded, color: AppColors.textMuted, size: 18)),
        SizedBox(height: 24),
        AppButton(label: 'Send Reset Code', onPressed: () => setState(() => _codeSent = true)),
      ] else ...[
        Center(child: Column(children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
            child: Icon(Icons.send_rounded, color: AppColors.primaryGreen, size: 36)),
          SizedBox(height: 16),
          Text('Code Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'A 4-digit reset code was sent to ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            TextSpan(text: '+254 7** *** 678', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 13)),
          ]), textAlign: TextAlign.center),
          SizedBox(height: 24),
          AppButton(label: 'Enter Code', onPressed: () => context.go('/otp', extra: _phoneCtrl.text)),
          SizedBox(height: 12),
          TextButton(onPressed: () {}, child: Text('Resend in 00:45', style: TextStyle(color: AppColors.secondaryGreen))),
        ])),
      ],
    ]),
  )),
);
```

---

## Screen 5 — OTP Verification

**File:** `lib/features/auth/pages/register_verify_page.dart`

```dart
// Countdown timer — Timer.periodic(Duration(seconds:1), callback)
// Use pinput package for OTP input

class OtpPage extends StatefulWidget {
  final String? phone;
}

// Key widgets:
// 1. Phone icon container
// 2. Heading + masked phone number
// 3. Pinput OTP boxes (see shared widget)
// 4. Verify button → dispatches OtpVerifyRequested to AuthBloc
// 5. Countdown + Resend link
```

---

## Screen 6–10 — Registration (Role-dependent)

**File:** `lib/features/auth/pages/register_init_page.dart`

### Progress Indicator
```dart
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text('Step $step of $total', style: Theme.of(context).textTheme.labelSmall),
    Text(stepLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textDark)),
  ]),
  SizedBox(height: 6),
  LinearProgressIndicator(
    value: step / total,
    minHeight: 6,
    backgroundColor: AppColors.lightGreen,
    valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
    borderRadius: AppRadius.full,
  ),
])
```

### Vehicle Type Selector (Transport only)
```dart
GridView.builder(
  shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.3),
  itemCount: vehicles.length,
  itemBuilder: (_, i) {
    final isSelected = _selectedVehicle == vehicles[i].type;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = vehicles[i].type),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : Colors.white,
          borderRadius: AppRadius.xl,
          border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.15),
            width: isSelected ? 2 : 1),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(vehicles[i].emoji, style: TextStyle(fontSize: 28)),
          SizedBox(height: 6),
          Text(vehicles[i].label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryGreen : AppColors.textMuted)),
        ]),
      ),
    );
  },
)
```

### M-Pesa Deposit Card (Transport only)
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFFFF8E7),
    borderRadius: AppRadius.xl,
    border: Border.all(color: AppColors.goldAccent.withOpacity(0.3)),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(Icons.warning_amber_rounded, color: AppColors.goldAccent),
      SizedBox(width: 8),
      Text('Refundable Deposit: KES 500', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    ]),
    SizedBox(height: 8),
    Text('Pay via M-Pesa PayBill 123456, Account: DEP-TRANSPORT-{your_id}. '
      'Fully refunded via B2C when you leave in good standing.',
      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
    SizedBox(height: 12),
    ElevatedButton(
      onPressed: _initiateDeposit, // Calls payment_helper.dart → launches M-Pesa deeplink
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldAccent,
        minimumSize: Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
      child: Text('Pay Deposit via M-Pesa', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
    ),
  ]),
)
```

---

## Screen 11 — Success

```dart
// Animated checkmark using TweenAnimationBuilder
// farm/market photo using CachedNetworkImage
// Button routes to /farmer or /buyer or /transport based on role

TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: 1),
  duration: Duration(milliseconds: 800),
  curve: Curves.elasticOut,
  builder: (_, val, __) => Transform.scale(
    scale: val,
    child: Container(
      width: 112, height: 112,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.secondaryGreen, AppColors.primaryGreen]),
        shape: BoxShape.circle,
        boxShadow: AppShadows.primary,
      ),
      child: Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 64),
    ),
  ),
)
```

---

## Screen 12 — Farmer Dashboard

**File:** `lib/features/farmer/pages/farmer_dashboard.dart`

### Widgets to build:
- `lib/features/farmer/widgets/revenue_chart_card.dart` — fl_chart AreaChart
- `lib/features/farmer/widgets/order_request_card.dart` — confirm/decline buttons
- `lib/features/farmer/widgets/earnings_summary.dart` — weekly bar chart
- `lib/features/farmer/widgets/product_card.dart` — inventory item with progress bar

### SliverAppBar approach:
```dart
CustomScrollView(slivers: [
  SliverAppBar(
    expandedHeight: 200,
    pinned: true,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primaryGreen, AppColors.secondaryGreen])),
        child: _HeaderContent(), // greeting, weather, avatar
      ),
    ),
  ),
  SliverPadding(
    padding: EdgeInsets.all(20),
    sliver: SliverList(delegate: SliverChildListDelegate([
      RevenueChartCard(),
      SizedBox(height: 16),
      _StatsGrid(),
      SizedBox(height: 16),
      _QuickActionsRow(),
      SizedBox(height: 16),
      _RecentOrdersList(),
      SizedBox(height: 16),
      _InventoryList(),
    ])),
  ),
])
```

### Revenue Chart (fl_chart)
```dart
// lib/features/farmer/widgets/revenue_chart_card.dart
import 'package:fl_chart/fl_chart.dart';

LineChart(LineChartData(
  gridData: FlGridData(show: false),
  titlesData: FlTitlesData(
    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles:AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(sideTitles: SideTitles(
      showTitles: true, interval: 1,
      getTitlesWidget: (val, _) => Text(['M','T','W','T','F','S','S'][val.toInt()],
        style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
    )),
  ),
  borderData: FlBorderData(show: false),
  lineBarsData: [LineChartBarData(
    spots: weekRevenue.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value / 1000)).toList(),
    isCurved: true,
    color: AppColors.secondaryGreen,
    barWidth: 2.5,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: true, color: AppColors.secondaryGreen.withOpacity(0.15)),
  )],
))
```

---

## Screen 13 — Product List

**File:** `lib/features/farmer/pages/product_list_page.dart`

```dart
// BLoC: ProductBloc with FetchProducts event
// State: ProductsLoaded | ProductLoading | ProductError

// Features:
// - Search bar in header
// - Category filter chips (horizontal scroll)
// - Product list with status badges (Active / Low Stock / Inactive)
// - Edit (pencil) + Delete (trash) icon buttons per item
// - FAB → /farmer/products/create
// - Swipe-to-delete with Dismissible widget
// - Pull-to-refresh with RefreshIndicator
```

---

## Screen 14 — Add Product

**File:** `lib/features/farmer/pages/product_create_page.dart`

```dart
// Form fields:
// 1. Multi-image picker (image_picker → GridView of thumbnails + add button)
// 2. Product name (text)
// 3. Category (DropdownButtonFormField)
// 4. Unit (DropdownButtonFormField: kg, bunch, piece, litre, tray)
// 5. Price per unit (number)
// 6. Available quantity (number)
// 7. Harvest/pack date (DatePicker)
// 8. Description (multiline TextField)
// Submit → ProductBloc CreateProduct event

// Validators (lib/shared/utils/form_validators.dart):
static String? validatePrice(String? val) {
  if (val == null || val.isEmpty) return 'Price is required';
  if (double.tryParse(val) == null) return 'Enter a valid number';
  if (double.parse(val) <= 0) return 'Price must be greater than 0';
  return null;
}
```

---

## Screen 15 — Order Requests

**File:** `lib/features/farmer/pages/order_requests_page.dart`

```dart
// Tab bar: New | Confirmed | Ready | All
// Each tab shows filtered list from OrderBloc

// Order card:
// - Order ID + status badge + timestamp
// - Buyer name + item summary
// - Amount (bold, green)
// - For "New" status: Confirm + Decline buttons
// - Dispatch OrderBloc ConfirmOrder or DeclineOrder

// 30-minute countdown shown for new orders (must respond before timeout)
// Use Timer.periodic
```

---

## Screen 16 — Order Detail (Farmer)

**File:** `lib/features/farmer/pages/order_detail_page.dart`

```dart
// Sections:
// 1. Order status card with 5-step vertical timeline
//    States: Placed → Paid (Escrow) → Farmer Confirmed → Ready → Transport Assigned
// 2. Order items list (product name, qty, unit price, subtotal)
// 3. Totals: subtotal | platform fee | your earnings
// 4. Buyer details (name, phone)
// 5. Confirm / Decline action buttons (if status === New)
// 6. "Mark as Ready" button (if status === Confirmed)
```

---

## Screen 17 — Farmer Earnings

**File:** `lib/features/farmer/pages/earnings_page.dart`

```dart
// Header: balance card with withdraw + history buttons
// Weekly bar chart: fl_chart BarChart
// Recent payouts list: payout vs withdrawal rows with color-coded amounts
// Withdraw bottom sheet → Enter amount → Confirm M-Pesa send
```

---

## Screen 18 — Buyer Dashboard

**File:** `lib/features/buyer/pages/buyer_dashboard.dart`

```dart
// Widgets:
// - Location selector row (Westlands → ChevronDown) 
// - Notification bell with badge (BLoC: NotificationBloc unread count)
// - Search bar → navigates to /buyer/catalog on tap
// - Banner/hero promo (CachedNetworkImage + gradient overlay)
// - Category chips (horizontal SingleChildScrollView)
// - Nearby farmers row (horizontal avatars)
// - Recommended products 2x2 GridView
// - Active order tracking strip (visible when order in transit)
```

---

## Screen 19 — Product Catalog

**File:** `lib/features/buyer/pages/product_catalog_page.dart`

```dart
// Features:
// - Search bar (active, dispatches ProductBloc SearchProducts)
// - Category filter chips
// - Sort button (bottom sheet: Price low-high, high-low, Nearest farmer, Rating)
// - Product count indicator ("86 products found")
// - 2-column grid of product cards
// - Pagination / infinite scroll with ScrollController
// - Wishlist heart toggle per product
```

---

## Screen 20 — Product Detail

**File:** `lib/features/buyer/pages/product_detail_page.dart`

```dart
// Layout: CustomScrollView with SliverAppBar (hero image) + SliverToBoxAdapter

// Sections:
// 1. Hero image with back btn, heart btn, badge chip
// 2. Product name + rating row
// 3. Price (large, green) + per unit
// 4. Farmer card → tappable → shows farmer profile
// 5. Availability chips: Available qty | Harvest date | Min order
// 6. Description text
// 7. Quantity stepper (minus / value / plus)
// 8. Sticky bottom bar: Total amount + "Add to Cart" button

// State: int _quantity = 1
// BLoC: CartBloc AddToCart event
```

---

## Screen 21 — Cart

**File:** `lib/features/buyer/pages/cart_page.dart`

```dart
// Grouped by farmer (sub-orders that will be split server-side)
// Each group: Farmer header → list of CartItem widgets
// CartItem: image | name | qty | price | delete
// Summary card: subtotal | delivery fee | platform fee | total
// Delivery address card → change address
// "Proceed to Payment" button → creates order → go to checkout

// BLoC: CartBloc
// Events: AddToCart | RemoveFromCart | UpdateQuantity | ClearCart
// States: CartLoaded | CartLoading | CartEmpty
```

---

## Screen 22 — M-Pesa Checkout

**File:** `lib/features/buyer/pages/checkout_page.dart`

```dart
// This is the most important payment screen in the app

// Widget layout:
// 1. M-Pesa instruction card:
//    - Numbered steps 1-6
//    - Paybill number (123456) with copy button
//    - Account number (ORD-{id}) with copy button
//    - Payment expiry countdown (14 min)
// 2. Payment summary (subtotal, delivery, fee, total)
// 3. Escrow info banner
// 4. "I Have Paid — Confirm" button

// Copy to clipboard:
Clipboard.setData(ClipboardData(text: orderId));
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Account number copied!'), backgroundColor: AppColors.primaryGreen)
);

// Countdown timer (Timer.periodic, 14 min = 840 seconds)
// Format: '${(seconds ~/ 60).toString().padLeft(2,'0')}:${(seconds % 60).toString().padLeft(2,'0')}'

// M-Pesa deeplink (optional, lib/services/payment_helper.dart):
Future<void> launchMpesa(String paybill, String account, double amount) async {
  final uri = Uri.parse('https://lipa.safaricom.co.ke/paybill?businessNumber=$paybill&accountNumber=$account&amount=${amount.toInt()}');
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

---

## Screen 23 — Order Tracking

**File:** `lib/features/buyer/pages/order_tracking_page.dart`

```dart
// Real-time via WebSocket or polling (every 30 seconds) through OrderBloc

// Sections:
// 1. Map preview (google_maps_flutter with driver marker)
// 2. Driver card: photo | name | vehicle | call button
// 3. Stats row: Distance | ETA | Rating
// 4. Full timeline (7 steps with live pulse on current step)

// Timeline steps with "LIVE" badge on active step:
const steps = [
  'Order Placed', 'Payment Received', 'Farmer Accepted',
  'Order Ready', 'Transport Assigned', 'On the Way', 'Delivered',
];

// Live driver location update via location_service.dart
// Animate driver marker on map when coordinates change
```

---

## Screen 24 — Order History

**File:** `lib/features/buyer/pages/order_history_page.dart`

```dart
// ListView of order cards
// Each card: ID | date | items summary | total | status badge | Reorder button
// Tap → order_tracking_page (for active) or order detail (for completed)
// Pull-to-refresh, infinite scroll
// BLoC: OrderBloc FetchOrderHistory event
```

---

## Screen 25 — Transport Dashboard

**File:** `lib/features/transport/pages/provider_dashboard.dart`

```dart
// Key: Online/Offline toggle stored in TripBloc (or local SharedPreferences for quick access)
// Header gradient changes: green (online) ↔ gray (offline)

// Sections:
// 1. Online toggle card (Switch widget, large toggle)
// 2. Today's stats row: Earnings | Deliveries | Distance
// 3. Weekly earnings bar chart (fl_chart)
// 4. Active delivery card (map preview + order info + "Mark Delivered" button) — only when online
// 5. New order offer card with countdown → Accept / Decline
// 6. Performance card: star rating + 3 progress bars
// 7. Vehicle status card

// Location service: run in background when online
// lib/services/location_service.dart → updates driver position via API
```

---

## Screen 26 — Available Orders

**File:** `lib/features/transport/pages/available_orders_page.dart`

```dart
// BLoC: TripBloc FetchAvailableTrips
// Each offer card:
// - Order ID + vehicle icon
// - Weight + distance
// - Route: pickup (green dot) → delivery (red dot) with connecting line
// - Fee (bold, green)
// - Accept + Decline buttons
// - Countdown timer (10 min) → offer auto-expires

// Accept dispatch: TripBloc AcceptTrip(orderId)
// On accept: navigate to /transport/pickup/{id}

// Timer example:
class _CountdownTimer extends StatefulWidget {
  final int seconds;
  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder or Timer.periodic
    return Text('${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2,'0')}',
      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning));
  }
}
```

---

## Screen 27 — Delivery OTP

**File:** `lib/features/transport/pages/delivery_page.dart`

```dart
// This screen handles the OTP-based proof of delivery
// IMPORTANT: This is a critical fraud-prevention flow

// Sections:
// 1. Buyer card (name, address)
// 2. "Enter Delivery OTP" heading + instruction
// 3. OtpInputField (4 boxes) — buyer reads code from their app
// 4. Delivery photo capture (camera_service.dart)
// 5. Warning card: 5-min OTP expiry, max 3 attempts, escrow release info
// 6. "Confirm Delivery" button

// Photo capture:
import 'package:image_picker/image_picker.dart';
final ImagePicker _picker = ImagePicker();
Future<void> _takePhoto() async {
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
  if (photo != null) setState(() => _deliveryPhoto = File(photo.path));
}

// Submit: TripBloc ConfirmDelivery(orderId, otp, deliveryPhoto)
// On success: show success bottom sheet → escrow released message → navigate to /transport
// On OTP failure: show error, decrement attempts counter, allow retry if attempts < 3
```

---

## Screen 28 — My Trips

**File:** `lib/features/transport/pages/my_trips_page.dart`

```dart
// Trip history list
// Each trip card: ID | route (from → to) | distance | fee | status | date
// Status: Completed (green) | Cancelled (red)
// Route visualization: green dot → connecting line → red dot (same as offers)
// Tap → trip_detail_page (earnings breakdown, ratings, photos)
```

---

## Screen 30 — Notifications

**File:** `lib/features/common/notifications_page.dart`

```dart
// BLoC: NotificationBloc FetchNotifications, MarkAllRead, MarkRead(id)
// Notification types: payment | order | transport | review | market | system
// Each notification row:
// - Emoji icon in colored circle
// - Title + description + time
// - Unread: left border accent + blue dot
// - Tap → navigate to relevant screen via go_router
// - "Mark all read" button in AppBar actions

// Deep link routing from push notification:
// lib/core/notification_service.dart
void handleNotificationTap(Map<String, dynamic> payload) {
  final deepLink = payload['deepLink'] as String?;
  if (deepLink != null) router.go(deepLink);
}
// Example payloads:
// { "deepLink": "/farmer/orders/123", "type": "order" }
// { "deepLink": "/buyer/orders/456/track", "type": "tracking" }
// { "deepLink": "/cart", "type": "promotion" }
```

---

## Screen 31 — Profile

**File:** `lib/features/common/profile_page.dart`

```dart
// Role-aware: shows role-specific stats + menu items

// Header: GradientHeader with avatar, name, phone, role badge
// Stats row: 3 cards (Earnings/Purchases | Rating | Orders/Trips)
// Verification status list: Phone | ID | Cooperative | GPS | Bank
//   Each: label + verified badge (green) or "Add" button (orange)
// Menu items: Wallet | Notifications | Settings | Help & Support
// Logout button (red, opens confirmation dialog)

// Verification status from AuthBloc / User model:
class VerificationStatus {
  final bool phone;
  final bool nationalId;
  final bool cooperative; // farmer only
  final bool gpsLocation; // farmer only
  final bool bankAccount;
  final bool vehicleDocuments; // transport only
  final bool depositPaid; // transport only
}
```

---

## Screen 32 — Settings

**File:** `lib/features/common/settings_page.dart`

```dart
// Sections:
// Account: Edit Profile | Change Password | Linked Accounts | Language
// Preferences: Notifications (Switch) | Dark Mode (Switch) | Location (Switch)
// Privacy & Legal: Privacy Policy | Terms | Delete Account

// Language: show dialog with English / Kiswahili options
// Uses translations: assets/translations/en.json + sw.json
// Localization package: easy_localization: ^3.x

// Dark mode: dispatches ThemeBloc event (lib/blocs/common/theme_bloc.dart)
// State persisted via shared_preferences

// Delete account: show confirmation dialog → AuthBloc DeleteAccount event
```

---

## Screen 33 — Help & Support

**File:** `lib/features/common/support_page.dart`

```dart
// Contact cards: Live Chat | Call | Email | WhatsApp
// FAQ accordion list (ExpansionTile or Accordion widget)
// Support ticket form: issue type (dropdown) + description (multiline) + submit

// WhatsApp deeplink:
Uri.parse('https://wa.me/254700262262?text=Hi+MAMBONAMI+support')

// Phone call:
Uri.parse('tel:+254700MAMBA')
```

---

## Services — `lib/services/`

### `location_service.dart`
```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<Position> trackLocation() => Geolocator.getPositionStream(
    locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
  );

  Future<Position> getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw Exception('Location denied');
    return await Geolocator.getCurrentPosition();
  }
}
```

### `camera_service.dart`
```dart
import 'package:image_picker/image_picker.dart';

class CameraService {
  final _picker = ImagePicker();

  Future<File?> capturePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1280,
    );
    return file != null ? File(file.path) : null;
  }

  Future<File?> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return file != null ? File(file.path) : null;
  }
}
```

### `payment_helper.dart`
```dart
import 'package:url_launcher/url_launcher.dart';

class PaymentHelper {
  static Future<void> launchMpesaPayBill({
    required String paybill,
    required String account,
    required double amount,
  }) async {
    // STK Push deeplink (launches M-Pesa app directly)
    final uri = Uri.parse(
      'https://lipa.safaricom.co.ke/paybill?businessNumber=$paybill&accountNumber=$account&amount=${amount.toInt()}'
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```

---

## Data Layer

### `lib/data/models/order.dart`
```dart
enum OrderStatus {
  cart, placed, paidEscrow, farmerConfirmed, farmerReady,
  transportAssigned, pickedUp, delivered, cancelled, disputed
}

class Order {
  final String id;
  final String uuid;
  final String farmerId;
  final String buyerId;
  final String? transportProviderId;
  final List<OrderItem> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double platformFee;
  final double total;
  final String mpesaPaybill;
  final String mpesaAccountNumber;  // ORD-{uuid}
  final DateTime? paymentReceivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### `lib/data/models/trip.dart`
```dart
enum VehicleType { motorcycle, pickup, van, lorry }

class Trip {
  final String id;
  final String orderId;
  final String providerId;
  final VehicleType vehicleType;
  final String pickupLocation;
  final String deliveryLocation;
  final double distanceKm;
  final double fee;
  final String status; // assigned | picked_up | delivered | cancelled
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? deliveryPhotoUrl;
}
```

### `lib/data/repositories/auth_repository.dart`
```dart
class AuthRepository {
  final ApiClient _api;
  final SecureStorage _storage;

  Future<AuthResponse> login(String phone, String password) =>
    _api.post('/api/v1/auth/login/', body: {'phone': phone, 'password': password});

  Future<void> sendOtp(String phone) =>
    _api.post('/api/v1/auth/send-otp/', body: {'phone': phone});

  Future<AuthResponse> verifyOtp(String phone, String otp) =>
    _api.post('/api/v1/auth/verify-otp/', body: {'phone': phone, 'otp': otp});

  Future<User> register(RegisterDto dto) =>
    _api.post('/api/v1/auth/register/', body: dto.toJson());
}
```

---

## pubspec.yaml — Complete Dependencies

```yaml
name: mambonami
description: Kenya's #1 Farm-to-Market Marketplace
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # Navigation
  go_router: ^14.0.0

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # DI
  get_it: ^7.7.0

  # Network
  dio: ^5.4.3

  # Storage
  flutter_secure_storage: ^9.2.1
  shared_preferences: ^2.3.0
  hive_flutter: ^1.1.0           # offline cache

  # UI
  google_fonts: ^6.2.1
  cached_network_image: ^3.3.1
  pinput: ^5.0.0                 # OTP input
  lottie: ^3.1.2                 # Animations

  # Maps
  google_maps_flutter: ^2.6.0
  geolocator: ^12.0.0

  # Charts
  fl_chart: ^0.68.0

  # Camera & Media
  image_picker: ^1.1.0

  # Payments
  url_launcher: ^6.3.0

  # Localization
  easy_localization: ^3.0.7

  # Notifications
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0

  # Utilities
  intl: ^0.19.0
  timeago: ^3.6.1
  equatable: ^2.0.5
  dartz: ^0.10.1                 # Either type for error handling

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  bloc_test: ^9.1.7
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

---

## Auth Guard — `lib/features/auth/auth_guard.dart`

```dart
// Protects all role-specific routes
// Reads stored role from SecureStorage → redirects correctly

class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;

    // Unauthenticated → /login
    if (authState is AuthUnauthenticated) {
      if (!state.matchedLocation.startsWith('/login') &&
          !state.matchedLocation.startsWith('/welcome') &&
          !state.matchedLocation.startsWith('/splash')) {
        return '/login';
      }
    }

    // Authenticated → redirect / to role-specific dashboard
    if (authState is AuthAuthenticated) {
      if (state.matchedLocation == '/' || state.matchedLocation == '/login') {
        return switch(authState.user.role) {
          UserRole.farmer    => '/farmer',
          UserRole.buyer     => '/buyer',
          UserRole.transport => '/transport',
          UserRole.retailer  => '/buyer', // Retailer uses buyer flow
        };
      }
    }

    return null; // No redirect
  }
}
```

---

## Deep Link Handling — `lib/core/notification_service.dart`

```dart
// Supports deep links from push notifications
// Payload: { "deepLink": "/buyer/orders/abc123/track", "type": "tracking" }

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final deepLink = message.data['deepLink'] as String?;
  if (deepLink != null) {
    // Use GoRouter to navigate
    router.go(deepLink);
  }
});

// Supported deep links:
// /farmer/orders/{id}          → farmer order detail
// /buyer/orders/{id}/track     → buyer order tracking  
// /cart                        → buyer cart (unauthenticated → login → cart)
// /transport/available         → available orders
// /notifications               → notification center
```

---

## Testing — `test/`

```dart
// lib/blocs/auth/auth_bloc_test.dart
void main() {
  group('AuthBloc', () {
    late AuthBloc bloc;
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
      bloc = AuthBloc(authRepository: repository, storage: MockSecureStorage());
    });

    blocTest<AuthBloc, AuthState>(
      'emits OtpSent when LoginRequested succeeds',
      build: () {
        when(() => repository.login(any(), any())).thenAnswer((_) async => AuthResponse(phone: '+254712345678'));
        return bloc;
      },
      act: (b) => b.add(LoginRequested(phone: '+254712345678', password: 'pass')),
      expect: () => [AuthLoading(), OtpSent(phone: '+254712345678')],
    );
  });
}
```

---

*End of MAMBONAMI Flutter Screen Specifications v2.0*  
*Visual reference: React prototype in `mambonami/web`*  
*33 screens · 4 roles · BLoC · go_router · fl_chart · M-Pesa escrow*
