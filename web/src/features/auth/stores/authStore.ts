import create from 'zustand';
import { login as apiLogin } from '../services/authService';
import { setToken, removeToken } from '../../../core/storage/secureStorage';
import { UserProfile } from '../types';

interface AuthState {
	user: UserProfile | null;
	login: (phone: string, password: string) => Promise<void>;
	logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
	user: null,
	login: async (phone: string, password: string) => {
		const data = await apiLogin({ phone, password });
		setToken(data.tokens.access);
		set({ user: data.user });
	},
	logout: () => {
		removeToken();
		set({ user: null });
	},
}));

export default useAuthStore;
