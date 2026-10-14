import {
	BarChart3,
	Heart,
	Home,
	Navigation,
	Package,
	Plus,
	ShoppingBasket,
	Store,
	Truck,
	UserCircle,
	Users,
} from 'lucide-react'
import { NavLink } from 'react-router-dom'

import { useAuth } from '../../core/contexts/AuthContext'
import { getRoleDashboardPath } from '../../core/utils/roleRoutes'
import { CartCountBadge } from '../components/ui'

type NavItem = {
	label: string
	path: string
	icon: typeof Home
	primary?: boolean
	showBadge?: boolean
}

function roleItems(role: string, dashboardPath: string): NavItem[] {
	if (role === 'buyer') {
		return [
			{ label: 'Home', path: dashboardPath, icon: Home },
			{ label: 'Orders', path: '/app/buyer/orders', icon: ShoppingBasket },
			{ label: 'Shop', path: '/app/buyer/products', icon: Store, primary: true },
			{ label: 'Saved', path: '/app/buyer/wishlist', icon: Heart },
			{ label: 'Profile', path: '/app/buyer/profile', icon: UserCircle },
		]
	}
	if (role === 'farmer') {
		return [
			{ label: 'Home', path: dashboardPath, icon: Home },
			{ label: 'Products', path: '/app/farmer/products', icon: Package },
			{ label: 'Add', path: '/app/farmer/products/new', icon: Plus, primary: true },
			{ label: 'Orders', path: '/app/farmer/orders', icon: ShoppingBasket },
			{ label: 'Profile', path: '/app/farmer/profile', icon: UserCircle },
		]
	}
	if (role === 'transport_provider') {
		return [
			{ label: 'Home', path: dashboardPath, icon: Home },
			{ label: 'Active', path: '/app/transport/active-jobs', icon: Navigation },
			{ label: 'Jobs', path: '/app/transport/jobs', icon: Truck, primary: true },
			{ label: 'Earnings', path: '/app/transport/earnings', icon: BarChart3 },
			{ label: 'Profile', path: '/app/transport/profile', icon: UserCircle },
		]
	}
	return [
		{ label: 'Home', path: dashboardPath, icon: Home },
		{ label: 'Orders', path: '/app/retailer/orders', icon: ShoppingBasket },
		{ label: 'Buy', path: '/app/retailer/products', icon: Store, primary: true },
		{ label: 'Suppliers', path: '/app/retailer/suppliers', icon: Users },
		{ label: 'Profile', path: '/app/retailer/profile', icon: UserCircle },
	]
}

export function MobileBottomNav() {
	const { isAuthenticated, user } = useAuth()
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)
	const role = typeof user?.role === 'string' ? user.role : ''
	const dashboardPath = getRoleDashboardPath(role, isAdmin)

	const items: NavItem[] = isAdmin
		? [
				{ label: 'Home', path: '/app/admin', icon: Home },
				{ label: 'Orders', path: '/app/admin/orders', icon: ShoppingBasket },
				{ label: 'Users', path: '/app/admin/users', icon: Users, primary: true },
				{ label: 'Products', path: '/app/admin/products', icon: Package },
				{ label: 'Reports', path: '/app/admin/analytics', icon: BarChart3 },
			]
		: isAuthenticated
			? roleItems(role, dashboardPath)
			: [
					{ label: 'Home', path: '/home', icon: Home },
					{ label: 'Produce', path: '/products', icon: Package },
					{ label: 'Cart', path: '/cart', icon: ShoppingBasket, primary: true, showBadge: true },
					{ label: 'Saved', path: '/wishlist', icon: Heart },
					{ label: 'Join', path: '/role-select', icon: UserCircle },
				]

	return (
		<nav
			aria-label="Mobile navigation"
			className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-background/95 px-2 pb-[max(0.25rem,env(safe-area-inset-bottom))] shadow-soft backdrop-blur-xl md:hidden"
		>
			<div className="mx-auto grid h-16 max-w-md grid-cols-5 items-end gap-1">
				{items.map(({ label, path, icon: Icon, primary, showBadge }) => (
					<NavLink
						key={`${label}-${path}`}
						to={path}
						end={path === dashboardPath || path === '/home'}
						className={({ isActive }) =>
							primary
								? `relative -top-2 flex flex-col items-center justify-center text-[10px] font-bold ${isActive ? 'text-primary' : 'text-primary-dark'}`
								: `relative flex h-full flex-col items-center justify-center gap-1 text-[10px] font-semibold transition active:scale-95 ${isActive ? 'text-primary' : 'text-muted-foreground'}`
						}
					>
						{({ isActive }) => (
							<>
								<span className={primary ? `flex h-12 w-12 items-center justify-center rounded-full border-4 border-background shadow-soft ${isActive ? 'bg-secondary text-secondary-foreground' : 'bg-primary text-primary-foreground'}` : 'relative flex items-center justify-center'}>
									<Icon className={primary ? 'h-5 w-5' : 'h-5 w-5'} />
									{!primary && isActive && <span className="absolute -bottom-2 h-1 w-1 rounded-full bg-primary" />}
									{showBadge && <span className="absolute -right-3 -top-2"><CartCountBadge /></span>}
								</span>
								<span className={primary ? 'mt-0.5 whitespace-nowrap' : 'truncate'}>{label}</span>
							</>
						)}
					</NavLink>
				))}
			</div>
		</nav>
	)
}
