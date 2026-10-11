import type { ReactNode } from 'react'
import { Navigate, useLocation, type RouteObject } from 'react-router-dom'

import { useAuth } from '../core/contexts/AuthContext'
import {
	AdminDashboardPage,
	AnalyticsAdminPage,
	AuditAdminPage,
	DisputesAdminPage,
	FarmersAdminPage,
	OrdersAdminPage,
	PayoutsAdminPage,
	ProductsAdminPage,
	RetailersAdminPage,
	StaffAdminPage,
	TransportersAdminPage,
	UsersAdminPage,
} from '../features/admin'
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
	{ path: '/app/admin', element: <AdminLayout><AdminDashboardPage /></AdminLayout> },
	{ path: '/app/admin/orders', element: <AdminLayout><OrdersAdminPage /></AdminLayout> },
	{ path: '/app/admin/products', element: <AdminLayout><ProductsAdminPage /></AdminLayout> },
	{ path: '/app/admin/retailers', element: <AdminLayout><RetailersAdminPage /></AdminLayout> },
	{ path: '/app/admin/staff', element: <AdminLayout><StaffAdminPage /></AdminLayout> },
	{ path: '/app/admin/analytics', element: <AdminLayout><AnalyticsAdminPage /></AdminLayout> },
	{ path: '/app/admin/users', element: <AdminLayout><UsersAdminPage /></AdminLayout> },
	{ path: '/app/admin/farmers', element: <AdminLayout><FarmersAdminPage /></AdminLayout> },
	{ path: '/app/admin/transport', element: <AdminLayout><TransportersAdminPage /></AdminLayout> },
	{ path: '/app/admin/disputes', element: <AdminLayout><DisputesAdminPage /></AdminLayout> },
	{ path: '/app/admin/payouts', element: <AdminLayout><PayoutsAdminPage /></AdminLayout> },
	{ path: '/app/admin/audit', element: <AdminLayout><AuditAdminPage /></AdminLayout> },
	{ path: '/app/admin/*', element: <Navigate to="/app/admin" replace /> },
	{ path: '/admin/orders', element: <Navigate to="/app/admin/orders" replace /> },
]
