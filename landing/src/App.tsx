import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { useEffect } from 'react'
import { AuthProvider, useAuth } from './core/contexts/AuthContext'

import { adminRoutes } from './router/admin'
import { privateRoutes } from './router/private'
import { NotFound } from './router/route-pages'
import { publicRoutes } from './router/public'

/**
 * ✅✅ APPLICATION BOOT SEQUENCE:
 * 1. App renders AuthProvider
 * 2. AuthProvider initializes auth on mount (restoreSession)
 * 3. Routes render only when isInitialized is true
 * 4. Protected routes check isAuthenticated + user role
 * 5. SplashPage is visual only (no auth logic)
 */

const router = createBrowserRouter([
	...publicRoutes,
	...privateRoutes,
	...adminRoutes,
	{ path: '*', element: <NotFound /> },
])

function AppContent() {
	const { isInitialized } = useAuth()

	// Don't render routes until auth is initialized
	if (!isInitialized) {
		return (
			<div className="flex items-center justify-center min-h-screen bg-white">
				<div className="text-center">
					<div className="text-2xl font-bold text-green-700 mb-4">MAMBONAMI</div>
					<div className="animate-pulse text-gray-600">Loading...</div>
				</div>
			</div>
		)
	}

	return <RouterProvider router={router} />
}

export function App() {
	return (
		<AuthProvider>
			<AppContent />
		</AuthProvider>
	)
}
