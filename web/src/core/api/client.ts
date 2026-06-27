// web/src/core/api/client.ts
import axios, { AxiosInstance, AxiosError } from 'axios';
import { API_BASE } from './endpoints';
import { getToken, removeToken, setToken } from '../storage/secureStorage';

const getCsrfToken = () => {
  if (typeof document === 'undefined') {
    return null;
  }

  const match = document.cookie.match(/(^|;)\s*csrftoken=([^;]+)/);
  return match ? decodeURIComponent(match[2]) : null;
};

/**
 * Create axios instance with default configuration
 */
export const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

/**
 * Request interceptor - Add auth token and CSRF token to all requests
 */
apiClient.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    (config.headers as Record<string, string | undefined>).Authorization = `Bearer ${token}`;
  }

  const csrfToken = getCsrfToken();
  if (csrfToken) {
    (config.headers as Record<string, string | undefined>)['X-CSRFToken'] = csrfToken;
  }

  return config;
});

/**
 * Response interceptor - Handle token refresh and auth errors
 */
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as any;

    // Handle 401 Unauthorized
    if (error.response?.status === 401) {
      // If it's a refresh token request, remove token and reject
      if (originalRequest.url?.includes('token/refresh')) {
        removeToken();
        return Promise.reject(error);
      }

      // Try to refresh token
      try {
        const refreshToken = localStorage.getItem('refreshToken');
        if (refreshToken) {
          const response = await axios.post(`${API_BASE}/api/token/refresh/`, {
            refresh: refreshToken,
          });

          const { access } = response.data;
          setToken(access);

          // Retry original request with new token
          originalRequest.headers.Authorization = `Bearer ${access}`;
          return apiClient(originalRequest);
        }
      } catch (refreshError) {
        removeToken();
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);
