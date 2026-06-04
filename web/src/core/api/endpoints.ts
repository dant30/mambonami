export const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000';

export const AUTH_ENDPOINTS = {
	login: '/api/users/login/',
	registerInit: '/api/users/register/init/',
	registerVerify: '/api/users/register/verify/',
	passwordResetInit: '/api/users/password-reset/init/',
	passwordResetVerify: '/api/users/password-reset/verify/',
	profile: '/api/users/profile/',
};
