import type { ReactNode } from 'react'
import { Navigate, useLocation, type RouteObject } from 'react-router-dom'

import { useAuth } from '../core/contexts/AuthContext'
import { OrdersAdminPage } from '../features/admin'
import { MainLayout } from '../shared/layouts'

function AdminLayout({ children }: { children: ReactNode }) {
	const { isAuthenticated, user } = useAuth()
	const location = useLocation()
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)
	if (!isAuthenticated) return <Navigate to="/login" replace state={{ returnTo: `${location.pathname}${location.search}` }} />
	if (!isAdmin) return <Navigate to="/" replace />
	return <MainLayout admin>{children}</MainLayout>
}

export const adminRoutes: RouteObject[] = [
	{ path: '/app/admin', element: <AdminLayout><OrdersAdminPage /></AdminLayout> },
	{ path: '/app/admin/*', element: <AdminLayout><OrdersAdminPage /></AdminLayout> },
	{ path: '/admin/orders', element: <AdminLayout><OrdersAdminPage /></AdminLayout> },
]
