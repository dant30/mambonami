import { apiClient } from '../../../api'
import { AUTH_ENDPOINTS } from '../../../api/endpoints'
import type { AuthResponse, AuthUser, LoginInput, PasswordResetInput, RegisterInitInput, RegisterInput, RegistrationStartResponse, RegistrationVerifyInput, TransportProfile } from '../../types'

export function login(input: LoginInput): Promise<AuthResponse> {
	return apiClient.post<AuthResponse>(AUTH_ENDPOINTS.login, input)
}

export function startRegistration(input: RegisterInitInput): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(AUTH_ENDPOINTS.registerInit, input)
}

export function startRegistrationTransaction(input: RegisterInput): Promise<RegistrationStartResponse> {
	return apiClient.post<RegistrationStartResponse>(AUTH_ENDPOINTS.registrationStart, input)
}

export function verifyRegistration(input: RegisterInput): Promise<AuthResponse> {
	return apiClient.post<AuthResponse>(AUTH_ENDPOINTS.registerVerify, input)
}

export function verifyRegistrationTransaction(input: RegistrationVerifyInput): Promise<AuthResponse> {
	return apiClient.post<AuthResponse>(AUTH_ENDPOINTS.registrationVerify, input)
}

export function requestPasswordReset(phone: string): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(AUTH_ENDPOINTS.passwordResetInit, { phone })
}

export function resetPassword(input: PasswordResetInput): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(AUTH_ENDPOINTS.passwordResetVerify, input)
}

export function getProfile() {
	return apiClient.get<AuthResponse['user']>(AUTH_ENDPOINTS.profile)
}

export function updateProfile(input: Partial<AuthUser> & Record<string, unknown>) {
	return apiClient.patch<AuthResponse['user']>(AUTH_ENDPOINTS.profile, input)
}

export function uploadAvatar(file: File) {
	const body = new FormData()
	body.append('avatar', file)
	return apiClient.patch<AuthResponse['user']>(AUTH_ENDPOINTS.avatar, body)
}

export function updateTransportProfile(input: Partial<TransportProfile>) {
	return apiClient.patch<AuthResponse['user']>(AUTH_ENDPOINTS.profile, input)
}

export function changePassword(input: { old_password: string; new_password: string; confirm_password: string }) {
	return apiClient.post<{ message: string }>(AUTH_ENDPOINTS.passwordChange, input)
}

export function verifyPasswordResetCode(input: { phone: string; otp: string }): Promise<{ valid: boolean }> {
	return apiClient.post<{ valid: boolean }>(AUTH_ENDPOINTS.passwordResetVerifyCode, input)
}

export function resendRegistration(registration_id: string): Promise<RegistrationStartResponse> {
	return apiClient.post<RegistrationStartResponse>(AUTH_ENDPOINTS.registrationResend, { registration_id })
}
