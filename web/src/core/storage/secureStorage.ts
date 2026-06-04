const STORAGE_KEY = 'access_token';

export const setToken = (token: string) => localStorage.setItem(STORAGE_KEY, token);
export const getToken = () => localStorage.getItem(STORAGE_KEY);
export const removeToken = () => localStorage.removeItem(STORAGE_KEY);
