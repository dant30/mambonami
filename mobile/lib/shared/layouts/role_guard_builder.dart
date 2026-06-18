// mobile/lib/shared/layouts/role_guard_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../config/role_routes.dart';

/// A builder widget that shows different UI based on the user's role.
///
/// Example:
/// ```dart
/// RoleGuardBuilder(
///   buyerBuilder: (context) => BuyerHomeScreen(),
///   farmerBuilder: (context) => FarmerHomeScreen(),
///   transportBuilder: (context) => TransportHomeScreen(),
///   adminBuilder: (context) => AdminHomeScreen(),
///   unauthorizedBuilder: (context) => UnauthorizedScreen(),
/// )
/// ```
class RoleGuardBuilder extends StatelessWidget {
  final Widget Function(BuildContext)? buyerBuilder;
  final Widget Function(BuildContext)? farmerBuilder;
  final Widget Function(BuildContext)? transportBuilder;
  final Widget Function(BuildContext)? adminBuilder;
  final Widget Function(BuildContext)? unauthorizedBuilder;

  const RoleGuardBuilder({
    super.key,
    this.buyerBuilder,
    this.farmerBuilder,
    this.transportBuilder,
    this.adminBuilder,
    this.unauthorizedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show loading state while authenticating
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          final role = state.role;
          switch (role) {
            case AppRole.buyer:
            case AppRole.retailer:
              if (buyerBuilder != null) return buyerBuilder!(context);
              break;
            case AppRole.farmer:
              if (farmerBuilder != null) return farmerBuilder!(context);
              break;
            case AppRole.transportProvider:
              if (transportBuilder != null) return transportBuilder!(context);
              break;
            case AppRole.admin:
              if (adminBuilder != null) return adminBuilder!(context);
              break;
          }
        }
        
        // Fallback for unauthenticated or missing builder
        if (unauthorizedBuilder != null) {
          return unauthorizedBuilder!(context);
        }
        return const Scaffold(
          body: Center(child: Text('Unauthorized access')),
        );
      },
    );
  }
}
