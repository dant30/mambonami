part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class RegisterInitEvent extends AuthEvent {
  final String phone;
  final String role;
  const RegisterInitEvent(this.phone, this.role);
  @override
  List<Object> get props => [phone, role];
}

class RegisterVerifyEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String username;
  final String password;
  final String role;
  final String? farmGps;
  final String? mpesaNumber;
  final String? vehicleType;
  final String? licensePlate;
  const RegisterVerifyEvent({
    required this.phone,
    required this.otp,
    required this.username,
    required this.password,
    required this.role,
    this.farmGps,
    this.mpesaNumber,
    this.vehicleType,
    this.licensePlate,
  });
  @override
  List<Object?> get props => [phone, otp, username, password, role, farmGps, mpesaNumber, vehicleType, licensePlate];
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;
  const LoginEvent(this.phone, this.password);
  @override
  List<Object> get props => [phone, password];
}

class ForgotPasswordInitEvent extends AuthEvent {
  final String phone;
  const ForgotPasswordInitEvent(this.phone);
  @override
  List<Object> get props => [phone];
}

class ForgotPasswordVerifyEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String newPassword;
  const ForgotPasswordVerifyEvent({required this.phone, required this.otp, required this.newPassword});
  @override
  List<Object> get props => [phone, otp, newPassword];
}

class LogoutEvent extends AuthEvent {}
class CheckAuthStatusEvent extends AuthEvent {}