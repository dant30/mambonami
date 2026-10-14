import { BarChart3, ClipboardList, FileCheck2, LogIn, LogOut, Navigation, Package, Plus, ShieldCheck, Truck, UserPlus, Users, X } from 'lucide-react'
import { NavLink, useNavigate } from 'react-router-dom'

import { useAuth } from '../../core/contexts/AuthContext'
import { CartCountBadge } from '../components/ui'

/**
 * ✅✅ SIDEBAR NAVIGATION:
 * Role-specific navigation sidebar for authenticated users.
 * Admin sidebar shows admin operations.
 * Marketplace sidebar shows role-specific dashboard + browsing.
 */
const adminItems = [
	{ path: '/app/admin', label: 'Dashboard', icon: ClipboardList },
	{ path: '/app/admin/orders', label: 'Orders', icon: ClipboardList },
	{ path: '/app/admin/products', label: 'Products', icon: Package },
	{ path: '/app/admin/retailers', label: 'Retailers', icon: Users },
	{ path: '/app/admin/analytics', label: 'Analytics', icon: BarChart3 },
	{ path: '/app/admin/staff', label: 'Staff', icon: ShieldCheck },
	{ path: '/app/admin/users', label: 'Users', icon: Users },
	{ path: '/app/admin/farmers', label: 'Farmers', icon: Package },
	{ path: '/app/admin/transport', label: 'Transport', icon: Truck },
	{ path: '/app/admin/disputes', label: 'Disputes', icon: ShieldCheck },
	{ path: '/app/admin/payouts', label: 'Payouts', icon: Navigation },
	{ path: '/app/admin/audit', label: 'Audit log', icon: FileCheck2 },
]

export interface SidebarProps {
	admin?: boolean
	mobileDrawer?: boolean
	onItemClick?: () => void
	onClose?: () => void
}

export function Sidebar({ admin = false, mobileDrawer = false, onItemClick, onClose }: SidebarProps) {
	const { user, isAuthenticated, logout } = useAuth()
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)
	const role = typeof user?.role === 'string' ? user.role : ''
	const navigate = useNavigate()

	// ✅✅ Dashboard path uses /app/{role} pattern
	const dashboardPath = isAdmin ? '/app/admin' : role === 'buyer' ? '/app/buyer' : role === 'farmer' ? '/app/farmer' : role === 'retailer' ? '/app/retailer' : role === 'transport_provider' ? '/app/transport' : '/'

	const marketplaceItems = !isAuthenticated
		? [
			{ path: '/home', label: 'Home', icon: ClipboardList },
			{ path: '/products', label: 'Browse produce', icon: Package },
			{ path: '/how-it-works', label: 'How it works', icon: Navigation },
			{ path: '/about', label: 'About Mambonami', icon: Users },
			{ path: '/support', label: 'Support', icon: ShieldCheck },
			{ path: '/cart', label: 'Cart', icon: Package, showBadge: true },
		]
		: role === 'buyer'
		? [
			{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
			{ path: '/app/buyer/products', label: 'Browse products', icon: Package },
			{ path: '/app/buyer/orders', label: 'Orders', icon: ClipboardList },
			{ path: '/app/buyer/wishlist', label: 'Wishlist', icon: Users },
			{ path: '/app/buyer/cart', label: 'Cart', icon: Package, showBadge: true },
			{ path: '/app/buyer/profile', label: 'Profile', icon: Users },
			{ path: '/app/buyer/settings', label: 'Settings', icon: ShieldCheck },
		]
		: role === 'farmer'
			? [
				{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
				{ path: '/app/farmer/orders', label: 'Orders received', icon: ClipboardList },
				{ path: '/app/farmer/products', label: 'My products', icon: Package },
				{ path: '/app/farmer/earnings', label: 'Earnings', icon: BarChart3 },
				{ path: '/app/farmer/profile', label: 'Profile', icon: Users },
				{ path: '/app/farmer/settings', label: 'Settings', icon: ShieldCheck },
			]
		: role === 'transport_provider'
			? [
				{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
				{ path: '/app/transport/jobs', label: 'Available jobs', icon: Truck },
				{ path: '/app/transport/active-jobs', label: 'Active trips', icon: Navigation },
				{ path: '/app/transport/vehicles', label: 'Vehicles', icon: Truck },
				{ path: '/app/transport/earnings', label: 'Earnings', icon: BarChart3 },
				{ path: '/app/transport/profile', label: 'Profile', icon: Users },
				{ path: '/app/transport/settings', label: 'Settings', icon: ShieldCheck },
			]
			: [
			{ path: dashboardPath, label: 'Dashboard', icon: ClipboardList },
			{ path: '/products', label: 'Browse produce', icon: Package },
			{ path: '/app/retailer/profile', label: 'Profile', icon: Users },
			{ path: '/app/retailer/settings', label: 'Settings', icon: ShieldCheck },
				{ path: dashboardPath, label: 'Workspace', icon: Users },
		]

	const items: Array<{ path: string; label: string; icon: typeof ClipboardList; showBadge?: boolean }> = admin ? adminItems : marketplaceItems

	return (
		<aside
			className={
				mobileDrawer
					? 'flex h-full min-h-full w-full flex-col overflow-hidden bg-background p-4 text-foreground'
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
					{mobileDrawer && <button type="button" onClick={onClose} aria-label="Close navigation drawer" className="rounded-full p-2 text-muted-foreground hover:bg-muted hover:text-foreground"><X className="h-5 w-5" /></button>}
			</div>

			<nav className="sidebar-nav-scrollbar min-h-0 flex-1 space-y-1 overflow-y-auto" aria-label={admin ? 'Admin links' : 'Marketplace links'}>
				{items.map(({ path, label, icon: Icon, showBadge }) => (
					<NavLink
						key={path}
						to={path}
						onClick={onItemClick}
						className={({ isActive }) =>
							`relative flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition ${
								isActive
									? 'bg-primary text-primary-foreground shadow-sm'
									: 'text-muted-foreground hover:bg-muted hover:text-foreground'
							}`
						}
					>
						<Icon className="h-4 w-4 shrink-0" />
						<span>{label}</span>
						{showBadge && path === '/app/buyer/cart' && (
							<span className="relative ml-auto">
								<CartCountBadge />
							</span>
						)}
					</NavLink>
				))}
			</nav>

			{!admin && isAuthenticated && <button type="button" onClick={() => navigate(role === 'farmer' ? '/app/farmer/products/new' : role === 'retailer' ? '/app/retailer/products' : role === 'transport_provider' ? '/app/transport/jobs' : '/app/buyer/products')} className="mt-4 flex shrink-0 items-center justify-center gap-2 rounded-xl bg-secondary px-3 py-3 text-sm font-bold text-secondary-foreground transition hover:brightness-95"><Plus className="h-4 w-4" />{role === 'farmer' ? 'Add product' : role === 'retailer' ? 'Find products' : role === 'transport_provider' ? 'Find jobs' : 'Shop produce'}</button>}
			{!admin && !isAuthenticated && <div className="mt-4 grid shrink-0 gap-2"><NavLink to="/login" onClick={onItemClick} className="flex items-center justify-center gap-2 rounded-xl border border-border px-3 py-3 text-sm font-bold text-primary-dark hover:bg-muted"><LogIn className="h-4 w-4" />Log in</NavLink><NavLink to="/role-select" onClick={onItemClick} className="flex items-center justify-center gap-2 rounded-xl bg-secondary px-3 py-3 text-sm font-bold text-secondary-foreground hover:brightness-95"><UserPlus className="h-4 w-4" />Get started</NavLink></div>}

			{admin && (
				<div className="mt-auto border-t border-border pt-4 text-xs text-muted-foreground">
					<ShieldCheck className="mb-2 h-5 w-5 text-primary" />
					<p>Staff-only workspace</p>
					<button type="button" onClick={() => { logout(); onItemClick?.(); navigate('/login') }} className="mt-3 flex min-h-11 w-full items-center justify-center gap-2 rounded-xl bg-muted px-3 py-3 font-bold text-destructive hover:bg-destructive/10"><LogOut className="h-4 w-4" />Log out</button>
				</div>
			)}

			{!admin && (
				<div className="mt-auto border-t border-border pt-4 text-xs text-muted-foreground">
					{isAuthenticated ? <button type="button" onClick={() => { logout(); onItemClick?.(); navigate('/login') }} className="flex w-full items-center justify-center gap-2 rounded-xl bg-muted px-3 py-3 font-bold text-destructive hover:bg-destructive/10"><LogOut className="h-4 w-4" />Log out</button> : <><Truck className="mb-2 h-5 w-5 text-primary" />From farm gate to doorstep</>}
				</div>
			)}
		</aside>
	)
}
