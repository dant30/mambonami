// lib/blocs/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

class RegisterInitEvent extends AuthEvent {
  final String phone;
  final String role;
  const RegisterInitEvent(this.phone, this.role);
  @override List<Object> get props => [phone, role];
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
  const RegisterVerifyEvent({required this.phone, required this.otp, required this.username, required this.password, required this.role, this.farmGps, this.mpesaNumber, this.vehicleType, this.licensePlate});
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;
  const LoginEvent(this.phone, this.password);
}

class LogoutEvent extends AuthEvent {}
class CheckAuthStatusEvent extends AuthEvent {}

// lib/blocs/auth/auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class RegisterInitSuccess extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String role;
  final String phone;
  const AuthAuthenticated(this.role, this.phone);
  @override List<Object> get props => [role, phone];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object> get props => [message];
}

// lib/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/secure_storage.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorage secureStorage;

  AuthBloc({required this.authRepository, required this.secureStorage}) : super(AuthInitial()) {
    on<RegisterInitEvent>(_onRegisterInit);
    on<RegisterVerifyEvent>(_onRegisterVerify);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onRegisterInit(RegisterInitEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.registerInit(event.phone, event.role);
      emit(RegisterInitSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterVerify(RegisterVerifyEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.registerVerify(
        phone: event.phone,
        otp: event.otp,
        username: event.username,
        password: event.password,
        role: event.role,
        farmGps: event.farmGps,
        mpesaNumber: event.mpesaNumber,
        vehicleType: event.vehicleType,
        licensePlate: event.licensePlate,
      );
      emit(AuthAuthenticated(user['role'], event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.phone, event.password);
      emit(AuthAuthenticated(user['role'], event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      // Verify token by fetching profile from backend. If this succeeds,
      // token is valid; otherwise handle as unauthenticated.
      final profile = await authRepository.getProfile();
      final role = profile['role'] as String? ?? await secureStorage.getUserRole();
      final phone = profile['phone'] as String? ?? await secureStorage.getUserPhone();
      if (role != null && phone != null) {
        // Ensure secure storage has the latest values
        await secureStorage.saveUserRole(role);
        await secureStorage.saveUserPhone(phone);
        emit(AuthAuthenticated(role, phone));
        return;
      }
    } catch (e) {
      // If profile fetch fails (401 or network), clear local auth state
      await secureStorage.clearAll();
    }
    emit(AuthUnauthenticated());
  }
}