// web/src/core/hooks/useAuth.ts
import { useContext } from 'react';
import { AuthContext } from '../../../core/context/AuthContext';

export const useAuth = () => {
	const ctx = useContext(AuthContext);
	if (!ctx) {
		throw new Error('useAuth must be used within AuthProvider');
	}
	return ctx;
};
