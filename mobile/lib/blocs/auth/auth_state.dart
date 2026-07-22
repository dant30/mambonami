// mobile/lib/blocs/auth/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phone;
  final String? password;
  const OtpSent({required this.phone, this.password});

  @override
  List<Object?> get props => [phone, password];
}

class OtpVerified extends AuthState {}

class RegisterSuccess extends AuthState {
  final String role;
  const RegisterSuccess(this.role);

  @override
  List<Object> get props => [role];
}

class RegisterInitSuccess extends AuthState {}

class RegisterOtpPending extends AuthState {
  final String phone;
  final Map<String, dynamic> dto;
  const RegisterOtpPending({required this.phone, required this.dto});

  @override
  List<Object?> get props => [phone, dto];
}

class ForgotPasswordInitSuccess extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  final String phone;
  final String? username;
  final String? avatarUrl;
  final String? displayName;
  final String? vehicleType;
  final String? licensePlate;
  final double? providerRating;
  final int? completedDeliveries;

  const AuthAuthenticated(
    this.role,
    this.phone, [
    this.username,
    this.avatarUrl,
    this.displayName,
    this.vehicleType,
    this.licensePlate,
    this.providerRating,
    this.completedDeliveries,
  ]);

  @override
  List<Object?> get props => [
        role,
        phone,
        username,
        avatarUrl,
        displayName,
        vehicleType,
        licensePlate,
        providerRating,
        completedDeliveries,
      ];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}
