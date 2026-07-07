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

class ForgotPasswordInitSuccess extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  final String phone;
  final String? username;

  const AuthAuthenticated(this.role, this.phone, [this.username]);

  @override
  List<Object?> get props => [role, phone, username];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}
