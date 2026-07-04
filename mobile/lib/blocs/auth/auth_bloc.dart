// mobile/lib/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/secure_storage.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorage secureStorage;

  AuthBloc({required this.authRepository, required this.secureStorage})
      : super(AuthInitial()) {
    on<RegisterInitEvent>(_onRegisterInit);
    on<RegisterVerifyEvent>(_onRegisterVerify);
    on<LoginEvent>(_onLogin);
    on<ForgotPasswordInitEvent>(_onForgotPasswordInit);
    on<ForgotPasswordVerifyEvent>(_onForgotPasswordVerify);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  String? _stringValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  Future<void> _onRegisterInit(
      RegisterInitEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.registerInit(event.phone, event.role);
      emit(RegisterInitSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterVerify(
      RegisterVerifyEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Registration data is validated after the repository call so we can
      // fail fast with a clear error if the backend omits required fields.
      final user = await authRepository.registerVerify(
        phone: event.phone,
        otp: event.otp,
        username: event.username,
        password: event.password,
        role: event.role,
        email: event.email,
        farmGps: event.farmGps,
        mpesaNumber: event.mpesaNumber,
        vehicleType: event.vehicleType,
        licensePlate: event.licensePlate,
      );
      
      final role = _stringValue(user, 'role');
      final phone = _stringValue(user, 'phone');
      final username = _stringValue(user, 'username') ?? event.username;

      if (role == null || phone == null) {
        throw Exception('Invalid user data from registration: missing role or phone');
      }
      
      emit(AuthAuthenticated(role, phone, username));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.phone, event.password);
      
      final role = _stringValue(user, 'role');
      final phone = _stringValue(user, 'phone') ?? event.phone;
      final username = _stringValue(user, 'username');

      if (role == null) {
        throw Exception('Invalid user data: missing role or phone');
      }
      
      emit(AuthAuthenticated(role, phone, username));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordInit(
      ForgotPasswordInitEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.forgotPasswordInit(event.phone);
      emit(ForgotPasswordInitSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPasswordVerify(
      ForgotPasswordVerifyEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.forgotPasswordVerify(
          event.phone, event.otp, event.newPassword);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      // Verify token by fetching profile from backend. If this succeeds,
      // token is valid; otherwise handle as unauthenticated.
      final profile = await authRepository.getProfile();
      final role = _stringValue(profile, 'role') ?? await secureStorage.getUserRole();
      final phone = _stringValue(profile, 'phone') ?? await secureStorage.getUserPhone();
      final username = _stringValue(profile, 'username');
      if (role != null && phone != null) {
        // Ensure secure storage has the latest values
        await secureStorage.saveUserRole(role);
        await secureStorage.saveUserPhone(phone);
        emit(AuthAuthenticated(role, phone, username));
        return;
      }
    } catch (e) {
      // If profile fetch fails (401 or network), clear local auth state
      await secureStorage.clearAll();
    }
    emit(AuthUnauthenticated());
  }
}
