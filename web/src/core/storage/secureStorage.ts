// web/src/core/storage/secureStorage.ts
const TOKEN_KEY = 'access_token';
const REFRESH_KEY = 'refresh_token';

export const setToken = (token: string) => localStorage.setItem(TOKEN_KEY, token);
export const getToken = () => localStorage.getItem(TOKEN_KEY);
export const removeToken = () => localStorage.removeItem(TOKEN_KEY);

export const setRefreshToken = (token: string) => localStorage.setItem(REFRESH_KEY, token);
export const getRefreshToken = () => localStorage.getItem(REFRESH_KEY);
export const removeRefreshToken = () => localStorage.removeItem(REFRESH_KEY);

export const clearAllTokens = () => {
  removeToken();
  removeRefreshToken();
};