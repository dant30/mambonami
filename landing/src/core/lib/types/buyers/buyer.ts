import type { CartItem, CartSummary, Order } from '../orders'
import type { Product, WishlistItem } from '../products'

export interface BuyerDashboardData {
	orders: Order[]
	activeOrder: Order | null
	wishlist: WishlistItem[]
	cart: CartItem[]
	cartSummary: CartSummary
}

export interface BuyerDashboardSummary {
	openOrderCount: number
	wishlistCount: number
	cartItemCount: number
	cartTotal: number
}

export interface BuyerOrderTimelineStep {
	status: string
	label: string
	complete: boolean
}

export interface BuyerWishlistProduct extends Product {
	wishlistItemId?: number
}
