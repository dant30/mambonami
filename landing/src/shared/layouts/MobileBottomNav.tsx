import { Heart, Home, Package, ShoppingBasket, UserCircle } from 'lucide-react'
import { Link, useLocation } from 'react-router-dom'

import { useAuth } from '../../core/contexts/AuthContext'
import { CartCountBadge } from '../components/ui'

/**
 * ✅✅ MOBILE BOTTOM NAVIGATION:
 * Role-specific navigation bar at bottom of mobile screen.
 * Shows different items based on auth state and user role.
 */
export function MobileBottomNav() {
	const { isAuthenticated, user } = useAuth()
	const location = useLocation()
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)
	const role = typeof user?.role === 'string' ? user.role : ''

	// ✅✅ Dashboard path uses /app/{role} pattern
	const dashboardPath = isAdmin ? '/app/admin' : role === 'buyer' ? '/app/buyer' : role === 'farmer' ? '/app/farmer' : role === 'retailer' ? '/app/retailer' : role === 'transport_provider' ? '/app/transport' : '/'
	const producePath = role === 'farmer' ? '/app/farmer/products' : role === 'retailer' ? '/app/retailer/products' : role === 'transport_provider' ? '/app/transport/jobs' : '/products'
	const produceLabel = role === 'farmer' ? 'Products' : role === 'retailer' ? 'Products' : role === 'transport_provider' ? 'Jobs' : 'Produce'
	const profilePath = role === 'buyer' ? '/app/buyer/profile' : role === 'farmer' ? '/app/farmer/profile' : role === 'retailer' ? '/app/retailer/profile' : role === 'transport_provider' ? '/app/transport/profile' : dashboardPath
	const profileLabel = role === 'buyer' ? 'Profile' : role === 'farmer' || role === 'retailer' || role === 'transport_provider' ? 'Profile' : 'Workspace'
	const activityPath = role === 'farmer' ? '/app/farmer/orders' : role === 'retailer' ? '/app/retailer/orders' : '/app/transport/active-jobs'
	const activityLabel = role === 'farmer' || role === 'retailer' ? 'Orders' : 'Active'

	const items = isAdmin
		? [
				{ label: 'Desk', path: '/app/admin', icon: Home },
				{ label: 'Orders', path: '/app/admin/orders', icon: ShoppingBasket },
				{ label: 'Users', path: '/app/admin/users', icon: UserCircle },
			]
		: isAuthenticated
			? role === 'buyer'
				? [
						{ label: 'Shop', path: '/app/buyer/products', icon: Package },
						{ label: 'Orders', path: '/app/buyer/orders', icon: ShoppingBasket },
						{ label: 'Wishlist', path: '/app/buyer/wishlist', icon: UserCircle },
						{ label: 'Cart', path: '/app/buyer/cart', icon: ShoppingBasket, showBadge: true },
						{ label: 'Dashboard', path: dashboardPath, icon: Home },
					]
				: [
						{ label: 'Home', path: dashboardPath, icon: Home },
						{ label: produceLabel, path: producePath, icon: Package },
						{ label: activityLabel, path: activityPath, icon: ShoppingBasket },
						{ label: profileLabel, path: profilePath, icon: UserCircle },
					]
			: [
					{ label: 'Home', path: '/home', icon: Home },
					{ label: 'Produce', path: '/products', icon: Package },
					{ label: 'Wishlist', path: '/wishlist', icon: Heart },
					{ label: 'Cart', path: '/cart', icon: ShoppingBasket, showBadge: true },
				]

	return (
		<nav
			className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-background px-2 pb-[max(0.5rem,env(safe-area-inset-bottom))] shadow-[0_-8px_24px_-18px_rgba(41,74,54,0.55)] md:hidden"
			aria-label="Mobile navigation"
		>
			<div className={`mx-auto grid max-w-md gap-1 ${isAuthenticated && role === 'buyer' ? 'grid-cols-5' : 'grid-cols-4'}`}>
				{items.map(({ label, path, icon: Icon, showBadge }) => {
					const active =
						location.pathname === path || (path !== '/home' && location.pathname.startsWith(path))

					return (
						<Link
							key={label}
							to={path}
							className={`relative flex min-h-14 flex-col items-center justify-center gap-1 text-[10px] font-semibold ${
								active
									? 'text-primary'
									: 'text-foreground/75 hover:text-foreground'
							}`}
						>
							<Icon className={`h-5 w-5 ${active ? 'scale-110' : ''}`} />
							{label}
							{showBadge && (
								<span className="absolute right-3 top-1.5">
									<CartCountBadge />
								</span>
							)}
						</Link>
					)
				})}
			</div>
		</nav>
	)
}
