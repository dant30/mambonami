export const setToken = (token: string) => localStorage.setItem('access_token', token);
export const getToken = () => localStorage.getItem('access_token');
export const removeToken = () => localStorage.removeItem('access_token');
