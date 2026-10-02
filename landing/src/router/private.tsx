import type { ReactNode } from 'react'
import { Navigate, useLocation, type RouteObject } from 'react-router-dom'

import { useAuth } from '../core/contexts/AuthContext'
import { BuyerDashboardPage } from '../features/buyers/pages/BuyerDashboardPage'
import { BuyerCartPage } from '../features/buyers/pages/BuyerCartPage'
import { BuyerOrderDetailPage } from '../features/buyers/pages/BuyerOrderDetailWorkspacePage'
import { BuyerOrdersPage } from '../features/buyers/pages/BuyerOrdersPage'
import { BuyerProductsPage } from '../features/buyers/pages/BuyerProductsPage'
import { BuyerProfilePage } from '../features/buyers/pages/BuyerProfilePage'
import { BuyerSettingsPage } from '../features/buyers/pages/BuyerSettingsPage'
import { BuyerWishlistPage } from '../features/buyers/pages/BuyerWishlistPage'
import { CheckoutPage } from '../features/home/pages'
import { ProductDetailPage } from '../features/home/pages/ProductDetailPage'
import { FarmerDashboardPage, FarmerEarningsPage, FarmerOrdersPage, FarmerProductFormPage, FarmerProductsPage, FarmerSubOrderDetailPage } from '../features/farmers/pages'
import { RetailerDashboardPage } from '../features/retailers/pages/RetailerDashboardPage'
import { RetailerInvoicesPage } from '../features/retailers/pages/RetailerInvoicesPage'
import { RetailerOrdersPage } from '../features/retailers/pages/RetailerOrdersPage'
import { RetailerProductsPage } from '../features/retailers/pages/RetailerProductsPage'
import { RetailerSuppliersPage } from '../features/retailers/pages'
import { TransporterDashboardPage } from '../features/transporters/pages/TransporterDashboardPage'
import { TransportEarningsPage } from '../features/transporters/pages/TransportEarningsPage'
import { TransportJobsPage } from '../features/transporters/pages/TransportJobsPage'
import { TransportTripDetailPage } from '../features/transporters/pages'
import { TransportTripsPage } from '../features/transporters/pages'
import { TransportVehiclesPage } from '../features/transporters/pages/TransportVehiclesPage'
import { MainLayout } from '../shared/layouts'

/**
 * ✅✅ ROUTE ARCHITECTURE:
 * - Public routes: `/home`, `/products`, `/product/:id`, `/login`, `/register`, etc.
 * - Authenticated app routes: `/app/{role}/*` (buyer, farmer, retailer, transport, admin)
 * - This clearly separates the public marketplace from authenticated business workspaces
 */

interface PrivateLayoutProps {
	children: ReactNode
	requiredRole?: string
}

function PrivateLayout({ children, requiredRole }: PrivateLayoutProps) {
	const { isAuthenticated, user } = useAuth()
	const location = useLocation()

	if (!isAuthenticated) {
		// Redirect to login with returnTo to preserve user's intended destination
		return <Navigate to="/login" replace state={{ returnTo: `${location.pathname}${location.search}` }} />
	}

	if (requiredRole && user?.role !== requiredRole) {
		// User is authenticated but not the correct role
		return <Navigate to={`/app/${user?.role || 'buyer'}`} replace />
	}

	return <MainLayout>{children}</MainLayout>
}

export const privateRoutes: RouteObject[] = [
	// ✅✅ Buyer workspace: /app/buyer/*
	{ path: '/app/buyer', element: <PrivateLayout requiredRole="buyer"><BuyerDashboardPage /></PrivateLayout> },
	{ path: '/app/buyer/products', element: <PrivateLayout requiredRole="buyer"><BuyerProductsPage /></PrivateLayout> },
	{ path: '/app/buyer/product/:id', element: <PrivateLayout requiredRole="buyer"><ProductDetailPage /></PrivateLayout> },
	{ path: '/app/buyer/orders', element: <PrivateLayout requiredRole="buyer"><BuyerOrdersPage /></PrivateLayout> },
	{ path: '/app/buyer/orders/:id', element: <PrivateLayout requiredRole="buyer"><BuyerOrderDetailPage /></PrivateLayout> },
	{ path: '/app/buyer/active-orders', element: <PrivateLayout requiredRole="buyer"><BuyerOrdersPage activeOnly /></PrivateLayout> },
	{ path: '/app/buyer/cart', element: <PrivateLayout requiredRole="buyer"><BuyerCartPage /></PrivateLayout> },
	{ path: '/app/buyer/wishlist', element: <PrivateLayout requiredRole="buyer"><BuyerWishlistPage /></PrivateLayout> },
	{ path: '/app/buyer/checkout', element: <PrivateLayout requiredRole="buyer"><CheckoutPage /></PrivateLayout> },
	{ path: '/app/buyer/profile', element: <PrivateLayout requiredRole="buyer"><BuyerProfilePage /></PrivateLayout> },
	{ path: '/app/buyer/settings', element: <PrivateLayout requiredRole="buyer"><BuyerSettingsPage /></PrivateLayout> },
	{ path: '/app/buyer/*', element: <PrivateLayout requiredRole="buyer"><BuyerDashboardPage /></PrivateLayout> },

	// ✅✅ Farmer workspace: /app/farmer/*
	{ path: '/app/farmer', element: <PrivateLayout requiredRole="farmer"><FarmerDashboardPage /></PrivateLayout> },
	{ path: '/app/farmer/products', element: <PrivateLayout requiredRole="farmer"><FarmerProductsPage /></PrivateLayout> },
	{ path: '/app/farmer/products/new', element: <PrivateLayout requiredRole="farmer"><FarmerProductFormPage /></PrivateLayout> },
	{ path: '/app/farmer/products/:id/edit', element: <PrivateLayout requiredRole="farmer"><FarmerProductFormPage /></PrivateLayout> },
	{ path: '/app/farmer/orders', element: <PrivateLayout requiredRole="farmer"><FarmerOrdersPage /></PrivateLayout> },
	{ path: '/app/farmer/orders/:id', element: <PrivateLayout requiredRole="farmer"><FarmerSubOrderDetailPage /></PrivateLayout> },
	{ path: '/app/farmer/sales', element: <PrivateLayout requiredRole="farmer"><FarmerEarningsPage /></PrivateLayout> },
	{ path: '/app/farmer/earnings', element: <PrivateLayout requiredRole="farmer"><FarmerEarningsPage /></PrivateLayout> },
	{ path: '/app/farmer/*', element: <PrivateLayout requiredRole="farmer"><FarmerDashboardPage /></PrivateLayout> },

	// ✅✅ Retailer workspace: /app/retailer/*
	{ path: '/app/retailer', element: <PrivateLayout requiredRole="retailer"><RetailerDashboardPage /></PrivateLayout> },
	{ path: '/app/retailer/products', element: <PrivateLayout requiredRole="retailer"><RetailerProductsPage /></PrivateLayout> },
	{ path: '/app/retailer/orders', element: <PrivateLayout requiredRole="retailer"><RetailerOrdersPage /></PrivateLayout> },
	{ path: '/app/retailer/suppliers', element: <PrivateLayout requiredRole="retailer"><RetailerSuppliersPage /></PrivateLayout> },
	{ path: '/app/retailer/invoices', element: <PrivateLayout requiredRole="retailer"><RetailerInvoicesPage /></PrivateLayout> },
	{ path: '/app/retailer/*', element: <PrivateLayout requiredRole="retailer"><RetailerDashboardPage /></PrivateLayout> },

	// ✅✅ Transport provider workspace: /app/transport/*
	{ path: '/app/transport', element: <PrivateLayout requiredRole="transport_provider"><TransporterDashboardPage /></PrivateLayout> },
	{ path: '/app/transport/jobs', element: <PrivateLayout requiredRole="transport_provider"><TransportJobsPage /></PrivateLayout> },
	{ path: '/app/transport/jobs/:id', element: <PrivateLayout requiredRole="transport_provider"><TransportTripDetailPage /></PrivateLayout> },
	{ path: '/app/transport/active-jobs', element: <PrivateLayout requiredRole="transport_provider"><TransportTripsPage /></PrivateLayout> },
	{ path: '/app/transport/completed-jobs', element: <PrivateLayout requiredRole="transport_provider"><TransportTripsPage completedOnly /></PrivateLayout> },
	{ path: '/app/transport/earnings', element: <PrivateLayout requiredRole="transport_provider"><TransportEarningsPage /></PrivateLayout> },
	{ path: '/app/transport/vehicles', element: <PrivateLayout requiredRole="transport_provider"><TransportVehiclesPage /></PrivateLayout> },
	{ path: '/app/transport/*', element: <PrivateLayout requiredRole="transport_provider"><TransporterDashboardPage /></PrivateLayout> },
]
