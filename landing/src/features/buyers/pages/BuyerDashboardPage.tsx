import { Heart, RefreshCw, Search, ShoppingBasket } from 'lucide-react'
import { Link } from 'react-router-dom'

import { useAuth } from '../../../core/contexts/AuthContext'
import { useActiveOrder, useOrders, useProductCategories, useProducts, useWishlist } from '../../../core/lib'
import { getTimeGreeting } from '../../../core/utils'
import { BuyerActiveOrder, BuyerCategoryScroller, BuyerProductRecommendations, BuyerQuickStats, BuyerRecentOrders, BuyerTrustFeatures, BuyerWishlistPreview } from '../components'

export function BuyerDashboardPage() {
	const { user } = useAuth()
	const { orders, isLoading: ordersLoading } = useOrders()
	const { order: activeOrder, isLoading: activeLoading } = useActiveOrder()
	const { items: wishlist, isLoading: wishlistLoading } = useWishlist()
	const { categories, isLoading: categoriesLoading } = useProductCategories()
	const { products, isLoading: productsLoading } = useProducts({ ordering: '-rating', in_stock: true, page_size: 4 })
	const openOrders = orders.filter((order) => !['delivered', 'cancelled'].includes(String(order.status || '').toLowerCase())).length
	const displayName = user?.first_name || 'Buyer'

	return (
		<main className="min-h-full bg-background">
			<div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8 lg:py-8">
				<section className="relative overflow-hidden rounded-3xl bg-primary-dark p-6 text-primary-foreground shadow-soft sm:p-8 lg:p-10">
					<div className="relative z-10 max-w-3xl">
						<p className="text-xs font-bold uppercase tracking-[0.2em] text-secondary">Mambonami marketplace</p>
						<h1 className="mt-3 text-3xl font-semibold sm:text-4xl">{getTimeGreeting()}, {displayName}.</h1>
						<p className="mt-3 text-sm leading-7 text-primary-foreground/70 sm:text-base">What are you looking for today?</p>
						<Link to="/app/buyer/products" className="mt-6 flex items-center gap-3 rounded-2xl bg-white px-4 py-3.5 text-left shadow-lg transition hover:bg-white/95"><Search className="h-5 w-5 shrink-0 text-slate-400" /><span className="text-sm text-slate-400">Search fresh produce, suppliers or categories...</span></Link>
						<div className="mt-5 grid grid-cols-2 gap-2 sm:flex sm:flex-wrap sm:gap-3">
							<Link to="/app/buyer/products" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full bg-secondary px-3 py-2.5 text-center text-xs font-bold text-primary-dark sm:px-5 sm:text-sm"><ShoppingBasket className="h-4 w-4" />Browse produce</Link>
							<Link to="/app/buyer/cart" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-primary-foreground/20 px-3 py-2.5 text-center text-xs font-bold text-primary-foreground hover:bg-primary-foreground/10 sm:px-5 sm:text-sm"><RefreshCw className="h-4 w-4" />Reorder</Link>
							<Link to="/app/buyer/wishlist" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-primary-foreground/20 px-3 py-2.5 text-center text-xs font-bold text-primary-foreground hover:bg-primary-foreground/10 sm:px-5 sm:text-sm"><Heart className="h-4 w-4" />Wishlist</Link>
							<Link to="/app/buyer/orders" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-primary-foreground/20 px-3 py-2.5 text-center text-xs font-bold text-primary-foreground hover:bg-primary-foreground/10 sm:px-5 sm:text-sm">My orders</Link>
						</div>
					</div>
					<div aria-hidden="true" className="absolute -right-24 -top-24 h-80 w-80 rounded-full border border-secondary/10" />
				</section>

				<BuyerQuickStats openOrders={openOrders} hasActiveOrder={Boolean(activeOrder)} wishlistCount={wishlist.length} isLoading={ordersLoading || activeLoading || wishlistLoading} />
				<BuyerCategoryScroller categories={categories} isLoading={categoriesLoading} />
				<BuyerActiveOrder order={activeOrder} isLoading={activeLoading} />
				<BuyerProductRecommendations products={products} isLoading={productsLoading} />
				<BuyerRecentOrders orders={orders} isLoading={ordersLoading} />
				<BuyerWishlistPreview items={wishlist} />
				<BuyerTrustFeatures />
			</div>
		</main>
	)
}
