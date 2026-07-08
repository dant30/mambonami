// mobile/lib/blocs/auth/auth_event.dart
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
  final String? email;
  final String? fullName;
  final String? ownerFullName;
  final String? nationalId;
  final String? farmGps;
  final String? mpesaNumber;
  final String? cooperative;
  final String? vehicleType;
  final String? licensePlate;
  final String? driverLicense;
  final String? bankAccount;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? businessName;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessAddress;
  final String? businessType;
  final String? kraPin;

  const RegisterVerifyEvent({
    required this.phone,
    required this.otp,
    required this.username,
    required this.password,
    required this.role,
    this.email,
    this.fullName,
    this.ownerFullName,
    this.nationalId,
    this.farmGps,
    this.mpesaNumber,
    this.cooperative,
    this.vehicleType,
    this.licensePlate,
    this.driverLicense,
    this.bankAccount,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.businessAddress,
    this.businessType,
    this.kraPin,
  });

  @override
  List<Object?> get props => [
        phone,
        otp,
        username,
        password,
        role,
        email,
        fullName,
        ownerFullName,
        nationalId,
        farmGps,
        mpesaNumber,
        cooperative,
        vehicleType,
        licensePlate,
        driverLicense,
        bankAccount,
        deliveryAddress,
        deliveryInstructions,
        businessName,
        businessPhone,
        businessEmail,
        businessAddress,
        businessType,
        kraPin,
      ];
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;
  const LoginEvent(this.phone, this.password);
  @override
  List<Object> get props => [phone, password];
}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  const LoginRequested({required this.phone, required this.password});
  @override
  List<Object> get props => [phone, password];
}

class OtpVerifyRequested extends AuthEvent {
  final String phone;
  final String otp;
  const OtpVerifyRequested({required this.phone, required this.otp});
  @override
  List<Object> get props => [phone, otp];
}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> dto;
  const RegisterRequested({required this.dto});
  @override
  List<Object> get props => [dto];
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
