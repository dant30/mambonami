import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api_client.dart';
import 'core/secure_storage.dart';
import 'core/notification_service.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/trip_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/connectivity/connectivity_bloc.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupDependencies();
  runApp(MyApp());
}

Future<void> setupDependencies() async {
  // Core
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<ApiClient>(ApiClient());
  
  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<ProductRepository>(ProductRepository());
  getIt.registerSingleton<OrderRepository>(OrderRepository());
  getIt.registerSingleton<TripRepository>(TripRepository());
  getIt.registerSingleton<NotificationRepository>(NotificationRepository());
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  getIt.registerSingleton<NotificationService>(notificationService);
  
  // BLoCs
  getIt.registerLazySingleton<NotificationBloc>(() => NotificationBloc(
    notificationRepository: getIt<NotificationRepository>(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = AppRouter().router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ConnectivityBloc()),
        BlocProvider(create: (_) => AuthBloc(authRepository: getIt<AuthRepository>(), secureStorage: getIt<SecureStorage>())),{
        BlocProvider(create: (_) => ProductBloc(productRepository: getIt<ProductRepository>())),
        BlocProvider(create: (_) => OrderBloc(orderRepository: getIt<OrderRepository>())),
        BlocProvider(create: (_) => TripBloc(tripRepository: getIt<TripRepository>())),
        BlocProvider(create: (_) => getIt<NotificationBloc>()..add(FetchNotificationsEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'MAMBONAMI',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: (context.watch<ThemeCubit>().state).themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}