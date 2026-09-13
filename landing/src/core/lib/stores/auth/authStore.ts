import { localStorageStore } from '../../../storage'
import type { AuthTokens, AuthUser } from '../../types'

export interface AuthSession {
	user: AuthUser | null
	tokens: AuthTokens | null
}

const emptySession: AuthSession = { user: null, tokens: null }

export const authStore = {
	getSession(): AuthSession {
		const user = localStorageStore.get<AuthUser>('user')
		const access = localStorageStore.get<string>('access_token')
		const refresh = localStorageStore.get<string>('refresh_token')
		return access ? { user, tokens: { access, ...(refresh ? { refresh } : {}) } } : emptySession
	},
	setSession(session: AuthSession): void {
		if (session.user) localStorageStore.set('user', session.user)
		else localStorageStore.remove('user')
		if (session.tokens?.access) localStorageStore.set('access_token', session.tokens.access)
		else localStorageStore.remove('access_token')
		if (session.tokens?.refresh) localStorageStore.set('refresh_token', session.tokens.refresh)
		else localStorageStore.remove('refresh_token')
	},
	clear(): void {
		authStore.setSession(emptySession)
	},
}