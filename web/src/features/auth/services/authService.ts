import { apiClient } from '../../../core/api/client';
import { AUTH_ENDPOINTS } from '../../../core/api/endpoints';
import { LoginResponse } from '../../../core/api/types';

export const login = async ({ phone, password }: { phone: string; password: string }): Promise<LoginResponse> => {
	const { data } = await apiClient.post<LoginResponse>(AUTH_ENDPOINTS.login, { phone, password });
	return data;
};

export const registerInit = async ({ phone, role }: { phone: string; role: string }) => {
	const { data } = await apiClient.post(AUTH_ENDPOINTS.registerInit, { phone, role });
	return data;
};

export const registerVerify = async (payload: any) => {
	const { data } = await apiClient.post(AUTH_ENDPOINTS.registerVerify, payload);
	return data;
};

export const passwordResetInit = async ({ phone }: { phone: string }) => {
	const { data } = await apiClient.post(AUTH_ENDPOINTS.passwordResetInit, { phone });
	return data;
};

export const passwordResetVerify = async (payload: any) => {
	const { data } = await apiClient.post(AUTH_ENDPOINTS.passwordResetVerify, payload);
	return data;
};

export const fetchProfile = async () => {
	const { data } = await apiClient.get('/api/users/profile/');
	return data;
};
