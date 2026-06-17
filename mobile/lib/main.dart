// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';               // ✅ NEW
import 'package:google_maps_flutter/google_maps_flutter.dart'; // ✅ for LatLng (optional but ensures type)

import 'core/api_client.dart';
import 'core/secure_storage.dart';
import 'core/notification_service.dart';
import 'core/deep_link_auth_listener.dart';
import 'core/storage/hive_geocode_cache.dart'; // ✅ NEW – your cache class
import 'config/routes.dart';
import 'config/theme.dart';
import 'data/local/cache_manager.dart';
import 'data/local/database_helper.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/trip_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/dispute_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/dispute/dispute_bloc.dart';
import 'blocs/theme/theme_bloc.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1. Initialize Hive for local caching
  await Hive.initFlutter();

  // Firebase (optional)
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } catch (error, stackTrace) {
    debugPrint('Firebase unavailable; continuing without push notifications: $error');
    debugPrint(stackTrace.toString());
  }

  await setupDependencies(firebaseAvailable);
  runApp(MyApp());
}

Future<void> setupDependencies(bool firebaseAvailable) async {
  // Core
  if (!getIt.isRegistered<SecureStorage>()) {
    getIt.registerSingleton<SecureStorage>(SecureStorage());
  }
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerSingleton<ApiClient>(ApiClient());
  }
  if (!getIt.isRegistered<CacheManager>()) {
    getIt.registerSingleton<CacheManager>(CacheManager.instance);
  }
  if (!getIt.isRegistered<DatabaseHelper>()) {
    getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);
  }
  await CacheManager.instance.init();
  await DatabaseHelper.instance.init();

  // ✅ 2. Initialize and register GeocodeCache
  if (!getIt.isRegistered<GeocodeCache>()) {
    final cache = GeocodeCache();
    await cache.init();
    getIt.registerSingleton<GeocodeCache>(cache);
  }

  // Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerSingleton<AuthRepository>(AuthRepository());
  }
  if (!getIt.isRegistered<CartRepository>()) {
    getIt.registerSingleton<CartRepository>(CartRepository());
  }
  await getIt<CartRepository>().init();
  if (!getIt.isRegistered<ProductRepository>()) {
    getIt.registerSingleton<ProductRepository>(ProductRepository());
  }
  if (!getIt.isRegistered<OrderRepository>()) {
    getIt.registerSingleton<OrderRepository>(OrderRepository());
  }
  if (!getIt.isRegistered<TripRepository>()) {
    getIt.registerSingleton<TripRepository>(TripRepository());
  }
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerSingleton<NotificationRepository>(NotificationRepository());
  }
  if (!getIt.isRegistered<DisputeRepository>()) {
    getIt.registerSingleton<DisputeRepository>(DisputeRepository());
  }

  // BLoCs
  if (!getIt.isRegistered<NotificationBloc>()) {
    getIt.registerLazySingleton<NotificationBloc>(() => NotificationBloc(
      notificationRepository: getIt<NotificationRepository>(),
    ));
  }

  // Initialize notification service when Firebase is available.
  if (firebaseAvailable && !getIt.isRegistered<NotificationService>()) {
    final notificationService = NotificationService();
    await notificationService.init();
    getIt.registerSingleton<NotificationService>(notificationService);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => AuthBloc(authRepository: getIt<AuthRepository>(), secureStorage: getIt<SecureStorage>())),
        BlocProvider(create: (_) => ProductBloc(productRepository: getIt<ProductRepository>())),
        BlocProvider(create: (_) => OrderBloc(orderRepository: getIt<OrderRepository>())),
        BlocProvider(create: (_) => TripBloc(tripRepository: getIt<TripRepository>())),
        BlocProvider(create: (_) => DisputeBloc(disputeRepository: getIt<DisputeRepository>())),
        BlocProvider(create: (_) => getIt<NotificationBloc>()..add(FetchNotificationsEvent())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'MAMBONAMI',
            theme: getLightTheme(),
            darkTheme: getDarkTheme(),
            themeMode: themeState.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return DeepLinkAuthListener(
                router: _router,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}