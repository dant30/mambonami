import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react'

import { AUTH_ENDPOINTS } from '../api/endpoints'
import { ApiError, apiClient } from '../api/apiClient'
import { addToWishlist, guestWishlistStore } from '../lib'

/**
 * ✅✅ SECURE TOKEN ARCHITECTURE:
 * - Access Token: Short-lived (15-60 min), stored in MEMORY (JS variable)
 *   → Auto-cleared on page refresh/close
 *   → Sent in Authorization header for API requests
 *   → Minimal XSS attack surface
 * 
 * - Refresh Token: Long-lived (7-14 days), in HttpOnly + Secure + SameSite cookie
 *   → Not accessible to JavaScript (prevents XSS theft)
 *   → Browser automatically includes with requests
 *   → Backend rotates token on each refresh (SimpleJWT ROTATE_REFRESH_TOKENS)
 * 
 * - User Data: Stored in memory (cleared on refresh)
 */

export interface AuthUser {
	id?: string | number
	phone?: string
	email?: string
	first_name?: string
	last_name?: string
	role?: string
	is_staff?: boolean
	is_superuser?: boolean
	isOnboarded?: boolean
	transport_profile?: {
		vehicle_type?: string
		capacity_kg?: number
		license_plate?: string
		driver_license?: string
		is_online?: boolean
		available?: boolean
	}
	[key: string]: unknown
}

export interface AuthTokens {
	access: string
	// refresh token is handled by HttpOnly cookie (not in JS)
}

interface LoginResponse {
	access?: string
	refresh?: string // May be set as HttpOnly cookie by backend
	tokens?: { access: string; refresh?: string }
	user: AuthUser
}

interface RegistrationStartResponse {
	challengeId: string
	message: string
	phone: string
	expiresIn: number
}

interface RegistrationVerifyResponse {
	access?: string
	refresh?: string
	tokens?: { access: string; refresh?: string }
	user: AuthUser
}

interface AuthContextValue {
	user: AuthUser | null
	accessToken: string | null
	isAuthenticated: boolean
	isInitialized: boolean
	isLoading: boolean
	
	// Authentication methods
	login(credentials: Record<string, unknown>): Promise<LoginResponse>
	
	// Challenge-based registration (✅✅ SECURE - no password in state)
	registrationStart(data: { phone: string; email: string; role: string }): Promise<RegistrationStartResponse>
	registrationVerify(challengeId: string, otp: string, password: string): Promise<RegistrationVerifyResponse>
	
	// Session management
	setSession(user: AuthUser | null, tokens: AuthTokens | null): void
	restoreSession(): Promise<void>
	logout(): void
	refreshAccessToken(): Promise<void>
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
	// ✅✅ Access token in memory (cleared on refresh)
	const [accessToken, setAccessToken] = useState<string | null>(null)
	const [user, setUser] = useState<AuthUser | null>(null)
	const [isLoading, setIsLoading] = useState(false)
	const [isInitialized, setIsInitialized] = useState(false)
	const restoreStarted = useRef(false)
	const sessionHintKey = 'mambonami_session_hint'

	useEffect(() => {
		apiClient.setAccessToken(accessToken)
	}, [accessToken])

	// ✅✅ Restore session on app boot (before rendering routes)
	const restoreSession = async () => {
		if (restoreStarted.current) return
		restoreStarted.current = true
		if (window.localStorage.getItem(sessionHintKey) !== '1') {
			setIsInitialized(true)
			return
		}
		try {
			// Attempt to refresh using HttpOnly cookie (browser sends it automatically)
			const response = await apiClient.post<{ access: string; user: AuthUser }>(AUTH_ENDPOINTS.tokenRefresh, {})
			apiClient.setAccessToken(response.access)
			setAccessToken(response.access)
			setUser(response.user)
		} catch (error) {
			// A transient outage or rate limit must not erase the cookie-session hint.
			setAccessToken(null)
			setUser(null)
			if (error instanceof ApiError && error.status === 401) {
				window.localStorage.removeItem(sessionHintKey)
			}
		} finally {
			setIsInitialized(true)
		}
	}

	// Initialize on app boot
	useEffect(() => {
		restoreSession()
	}, [])

	const setSession = (nextUser: AuthUser | null, nextTokens: AuthTokens | null) => {
		apiClient.setAccessToken(nextTokens?.access ?? null)
		setUser(nextUser)
		setAccessToken(nextTokens?.access ?? null)
	}

	const migrateGuestWishlist = async () => {
		const guestItems = guestWishlistStore.getItems()
		if (guestItems.length === 0) return
		const results = await Promise.allSettled(guestItems.map((product) => addToWishlist(product.uuid)))
		const failedItems = guestItems.filter((_, index) => results[index]?.status === 'rejected')
		guestWishlistStore.clear()
		failedItems.forEach((product) => guestWishlistStore.add(product))
	}

	const login = async (credentials: Record<string, unknown>) => {
		setIsLoading(true)
		try {
			const response = await apiClient.post<LoginResponse>(AUTH_ENDPOINTS.login, credentials)
			// Refresh token is automatically set as HttpOnly cookie by backend
			// We only store access token in memory
			setSession(response.user, { access: response.access ?? response.tokens?.access ?? '' })
			window.localStorage.setItem(sessionHintKey, '1')
			await migrateGuestWishlist()
			return response
		} finally {
			setIsLoading(false)
		}
	}

	// ✅✅ Challenge-based registration (SECURE - never passes password through state)
	const registrationStart = async (data: { phone: string; email: string; role: string }) => {
		setIsLoading(true)
		try {
			const response = await apiClient.post<RegistrationStartResponse>(
				'/api/auth/registration/start',
				data
			)
			return response
		} finally {
			setIsLoading(false)
		}
	}

	const registrationVerify = async (challengeId: string, otp: string, password: string) => {
		setIsLoading(true)
		try {
			const response = await apiClient.post<RegistrationVerifyResponse>(
				'/api/auth/registration/verify',
				{ challengeId, otp, password }
			)
			// Set session with access token (refresh token in HttpOnly cookie)
			setSession(response.user, { access: response.access ?? response.tokens?.access ?? '' })
			window.localStorage.setItem(sessionHintKey, '1')
			await migrateGuestWishlist()
			return response
		} finally {
			setIsLoading(false)
		}
	}

	const refreshAccessToken = async () => {
		try {
			const response = await apiClient.post<{ access: string }>(AUTH_ENDPOINTS.tokenRefresh, {})
			apiClient.setAccessToken(response.access)
			setAccessToken(response.access)
		} catch (error) {
			if (error instanceof ApiError && error.status === 401) {
				setSession(null, null)
				window.localStorage.removeItem(sessionHintKey)
			}
			throw error
		}
	}

	const logout = () => {
		setSession(null, null)
		window.localStorage.removeItem(sessionHintKey)
		// Optionally notify backend to invalidate refresh token
		apiClient.post(AUTH_ENDPOINTS.logout, {}).catch(() => {
			// Ignore errors on logout
		})
	}

	return (
		<AuthContext.Provider
			value={{
				user,
				accessToken,
				isAuthenticated: Boolean(accessToken && user),
				isInitialized,
				isLoading,
				login,
				registrationStart,
				registrationVerify,
				setSession,
				restoreSession,
				logout,
				refreshAccessToken,
			}}
		>
			{children}
		</AuthContext.Provider>
	)
}

export function useAuth() {
	const context = useContext(AuthContext)
	if (!context) throw new Error('useAuth must be used inside AuthProvider')
	return context
}
