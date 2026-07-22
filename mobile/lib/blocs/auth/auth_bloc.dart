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
    on<LoginRequested>(_onLoginRequested);
    on<OtpVerifyRequested>(_onOtpVerifyRequested);
    on<RegisterRequested>(_onRegisterRequested);
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

  String? _avatarUrl(Map<String, dynamic> user) {
    return _stringValue(user, 'avatar_url') ??
        _stringValue(user, 'profile_image') ??
        _stringValue(user, 'avatar');
  }

  String? _displayName(Map<String, dynamic> user, {String? fallback}) {
    return _stringValue(user, 'display_name') ??
        _stringValue(user, 'full_name') ??
        _stringValue(user, 'username') ??
        fallback;
  }

  String? _vehicleType(Map<String, dynamic> user) {
    return _stringValue(user, 'vehicle_type') ??
        _stringValue(user, 'vehicleType');
  }

  String? _licensePlate(Map<String, dynamic> user) {
    return _stringValue(user, 'license_plate') ??
        _stringValue(user, 'licensePlate');
  }

  double? _providerRating(Map<String, dynamic> user) {
    final value = user['provider_rating'] ?? user['providerRating'];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _completedDeliveries(Map<String, dynamic> user) {
    final value = user['completed_deliveries'] ?? user['completedDeliveries'];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
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
        fullName: event.fullName,
        ownerFullName: event.ownerFullName,
        nationalId: event.nationalId,
        farmGps: event.farmGps,
        mpesaNumber: event.mpesaNumber,
        cooperative: event.cooperative,
        vehicleType: event.vehicleType,
        licensePlate: event.licensePlate,
        driverLicense: event.driverLicense,
        bankAccount: event.bankAccount,
        deliveryAddress: event.deliveryAddress,
        deliveryInstructions: event.deliveryInstructions,
        businessName: event.businessName,
        businessPhone: event.businessPhone,
        businessEmail: event.businessEmail,
        businessAddress: event.businessAddress,
        businessType: event.businessType,
        kraPin: event.kraPin,
      );

      final role = _stringValue(user, 'role');
      final phone = _stringValue(user, 'phone');

      if (role == null || phone == null) {
        throw Exception(
            'Invalid user data from registration: missing role or phone');
      }

      emit(RegisterSuccess(role));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    await _onLoginRequested(
      LoginRequested(phone: event.phone, password: event.password),
      emit,
    );
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.phone, event.password);
      final role = _stringValue(user, 'role');
      final phone = _stringValue(user, 'phone') ?? event.phone;
      final username = _stringValue(user, 'username');
      final avatarUrl = _avatarUrl(user);
      final displayName = _displayName(user, fallback: username);
      final vehicleType = _vehicleType(user);
      final licensePlate = _licensePlate(user);
      final providerRating = _providerRating(user);
      final completedDeliveries = _completedDeliveries(user);

      if (role == null) {
        throw Exception('Invalid user data: missing role');
      }

      emit(AuthAuthenticated(
        role,
        phone,
        username,
        avatarUrl,
        displayName,
        vehicleType,
        licensePlate,
        providerRating,
        completedDeliveries,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpVerifyRequested(
      OtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.otp.length != 4) {
        throw Exception('Enter a valid 4-digit code');
      }

      final phone = event.phone.isNotEmpty
          ? event.phone
          : (state is OtpSent ? (state as OtpSent).phone : null);
      final password = state is OtpSent ? (state as OtpSent).password : null;
      if (phone == null || phone.isEmpty) {
        throw Exception('Missing phone number for OTP verification');
      }

      final user = await authRepository.loginVerifyOtp(
        phone: phone,
        otp: event.otp,
        password: password,
      );

      final role = _stringValue(user, 'role');
      final resolvedPhone = _stringValue(user, 'phone') ?? phone;
      final username = _stringValue(user, 'username');
      final avatarUrl = _avatarUrl(user);
      final displayName = _displayName(user, fallback: username);
      final vehicleType = _vehicleType(user);
      final licensePlate = _licensePlate(user);
      final providerRating = _providerRating(user);
      final completedDeliveries = _completedDeliveries(user);

      if (role == null) {
        throw Exception('Invalid user data: missing role or phone');
      }

      emit(AuthAuthenticated(
        role,
        resolvedPhone,
        username,
        avatarUrl,
        displayName,
        vehicleType,
        licensePlate,
        providerRating,
        completedDeliveries,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final role = event.dto['role']?.toString() ?? 'buyer';
      final phone = event.dto['phone']?.toString() ?? '';
      if (phone.isEmpty) {
        emit(const AuthError('Phone number is required for registration'));
        return;
      }

      await authRepository.registerInit(phone, role);
      emit(RegisterOtpPending(phone: phone, dto: event.dto));
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
      if (event.newPassword.isEmpty) {
        throw Exception('New password is required');
      }
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
      final role =
          _stringValue(profile, 'role') ?? await secureStorage.getUserRole();
      final phone =
          _stringValue(profile, 'phone') ?? await secureStorage.getUserPhone();
      final username = _stringValue(profile, 'username');
      final avatarUrl = _avatarUrl(profile);
      final displayName = _displayName(profile, fallback: username);
      final vehicleType = _vehicleType(profile);
      final licensePlate = _licensePlate(profile);
      final providerRating = _providerRating(profile);
      final completedDeliveries = _completedDeliveries(profile);
      if (role != null && phone != null) {
        // Ensure secure storage has the latest values
        await secureStorage.saveUserRole(role);
        await secureStorage.saveUserPhone(phone);
        emit(AuthAuthenticated(
          role,
          phone,
          username,
          avatarUrl,
          displayName,
          vehicleType,
          licensePlate,
          providerRating,
          completedDeliveries,
        ));
        return;
      }
    } catch (e) {
      // If profile fetch fails (401 or network), clear local auth state
      await secureStorage.clearAll();
    }
    emit(AuthUnauthenticated());
  }
}
