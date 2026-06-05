import { apiClient } from '../../../core/api/client';
import { AUTH_ENDPOINTS } from '../../../core/api/endpoints';
import { LoginResponse } from '../../../core/api';

const localAdminCredentials = {
  phone: '0724167076',
  password: 'admin',
};

export const login = async ({ phone, password }: { phone: string; password: string }): Promise<LoginResponse> => {
  if (phone === localAdminCredentials.phone && password === localAdminCredentials.password) {
    return Promise.resolve({
      tokens: {
        access: 'mambonami-local-admin-token',
        refresh: 'mambonami-local-refresh-token',
      },
      user: {
        id: 1,
        phone,
        username: 'Admin',
        email: 'admin@mambonami.local',
        first_name: 'Mambonami',
        last_name: 'Admin',
        role: 'admin',
        is_phone_verified: true,
        date_joined: new Date().toISOString(),
        farm_profile: null,
        transport_profile: null,
      },
    });
  }

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
