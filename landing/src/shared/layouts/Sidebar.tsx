import { BarChart3, ClipboardList, FileCheck2, Navigation, Package, ShieldCheck, Truck, Users, X } from 'lucide-react'
import { NavLink } from 'react-router-dom'

import { useAuth } from '../../core/contexts/AuthContext'

/**
 * ✅✅ SIDEBAR NAVIGATION:
 * Role-specific navigation sidebar for authenticated users.
 * Admin sidebar shows admin operations.
 * Marketplace sidebar shows role-specific dashboard + browsing.
 */
const adminItems = [
	{ path: '/app/admin', label: 'Dashboard', icon: ClipboardList },
	{ path: '/app/admin/users', label: 'Users', icon: Users },
	{ path: '/app/admin/products', label: 'Products', icon: Package },
	{ path: '/app/admin/analytics', label: 'Analytics', icon: BarChart3 },
	{ path: '/app/admin/audit', label: 'Audit log', icon: FileCheck2 },
]

export interface SidebarProps {
	admin?: boolean
	mobileDrawer?: boolean
	onItemClick?: () => void
	onClose?: () => void
}

export function Sidebar({ admin = false, mobileDrawer = false, onItemClick, onClose }: SidebarProps) {
	const { user } = useAuth()
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)
	const role = typeof user?.role === 'string' ? user.role : ''

	// ✅✅ Dashboard path uses /app/{role} pattern
	const dashboardPath = isAdmin ? '/app/admin' : role === 'buyer' ? '/app/buyer' : role === 'farmer' ? '/app/farmer' : role === 'retailer' ? '/app/retailer' : role === 'transport_provider' ? '/app/transport' : '/'

	const marketplaceItems = role === 'buyer'
		? [
			{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
			{ path: '/app/buyer/products', label: 'Browse products', icon: Package },
			{ path: '/app/buyer/orders', label: 'Orders', icon: ClipboardList },
			{ path: '/app/buyer/wishlist', label: 'Wishlist', icon: Users },
			{ path: '/app/buyer/cart', label: 'Cart', icon: Package },
			{ path: '/app/buyer/profile', label: 'Profile', icon: Users },
			{ path: '/app/buyer/settings', label: 'Settings', icon: ShieldCheck },
		]
		: role === 'farmer'
			? [
				{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
				{ path: '/app/farmer/orders', label: 'Orders received', icon: ClipboardList },
				{ path: '/app/farmer/products', label: 'My products', icon: Package },
				{ path: '/app/farmer/earnings', label: 'Earnings', icon: BarChart3 },
			]
		: role === 'transport_provider'
			? [
				{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
				{ path: '/app/transport/jobs', label: 'Available jobs', icon: Truck },
				{ path: '/app/transport/active-jobs', label: 'Active trips', icon: Navigation },
				{ path: '/app/transport/vehicles', label: 'Vehicles', icon: Truck },
				{ path: '/app/transport/earnings', label: 'Earnings', icon: BarChart3 },
			]
			: [
			{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
			{ path: '/products', label: 'Browse produce', icon: Package },
			{ path: '/profile', label: 'My profile', icon: Users },
		]

	const items = admin ? adminItems : marketplaceItems

	return (
		<aside
			className={
				mobileDrawer
					? 'flex w-full flex-col bg-primary-dark p-4 text-primary-foreground'
					: 'sticky top-16 hidden h-[calc(100vh-4rem)] w-60 shrink-0 flex-col border-r border-border bg-background px-3 py-5 md:flex'
			}
			aria-label={admin ? 'Admin navigation' : 'Marketplace navigation'}
		>
				<div className="mb-5 flex items-start justify-between border-b border-border px-3 pb-4">
					<div>
				<p className="text-[10px] font-bold uppercase tracking-[0.18em] text-muted-foreground">
					{admin ? 'Operations' : 'Marketplace'}
				</p>
				<p className="mt-1 font-display text-lg font-bold text-primary-dark">MAMBONAMI</p>
					</div>
					{mobileDrawer && <button type="button" onClick={onClose} aria-label="Close navigation drawer" className="rounded-full p-2 text-primary-foreground/70 hover:bg-primary-foreground/10 hover:text-primary-foreground"><X className="h-5 w-5" /></button>}
			</div>

			<nav className="space-y-1" aria-label={admin ? 'Admin links' : 'Marketplace links'}>
				{items.map(({ path, label, icon: Icon }) => (
					<NavLink
						key={path}
						to={path}
						onClick={onItemClick}
						className={({ isActive }) =>
							`flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition ${
								isActive
									? 'bg-primary text-primary-foreground shadow-sm'
									: 'text-muted-foreground hover:bg-muted hover:text-foreground'
							}`
						}
					>
						<Icon className="h-4 w-4 shrink-0" />
						{label}
					</NavLink>
				))}
			</nav>

			{admin && (
				<div className="mt-auto border-t border-border pt-4 text-xs text-muted-foreground">
					<ShieldCheck className="mb-2 h-5 w-5 text-primary" />
					Staff-only workspace
				</div>
			)}

			{!admin && (
				<div className="mt-auto border-t border-border pt-4 text-xs text-muted-foreground">
					<Truck className="mb-2 h-5 w-5 text-primary" />
					From farm gate to doorstep
				</div>
			)}
		</aside>
	)
}
