import type { BuyerDashboardData, BuyerDashboardSummary } from '../../types'
import type { CartItem, CartSummary, Order, WishlistItem } from '../../types'

let orders: Order[] = []
let activeOrder: Order | null = null
let wishlist: WishlistItem[] = []
let cart: CartItem[] = []
let cartSummary: CartSummary = { itemCount: 0, totalQuantity: 0, subtotal: 0, delivery_fee: 0, total: 0 }
let summary: BuyerDashboardSummary | null = null

export const buyerStore = {
	getOrders: () => orders,
	setOrders: (next: Order[]) => { orders = next },
	getActiveOrder: () => activeOrder,
	setActiveOrder: (next: Order | null) => { activeOrder = next },
	getWishlist: () => wishlist,
	setWishlist: (next: WishlistItem[]) => { wishlist = next },
	getCart: () => cart,
	setCart: (next: CartItem[]) => { cart = next },
	getCartSummary: () => cartSummary,
	setCartSummary: (next: CartSummary) => { cartSummary = next },
	getSummary: () => summary,
	setSummary: (next: BuyerDashboardSummary | null) => { summary = next },
	setDashboardData: (data: BuyerDashboardData, nextSummary: BuyerDashboardSummary) => {
		orders = data.orders
		activeOrder = data.activeOrder
		wishlist = data.wishlist
		cart = data.cart
		cartSummary = data.cartSummary
		summary = nextSummary
	},
	clear: () => {
		orders = []
		activeOrder = null
		wishlist = []
		cart = []
		cartSummary = { itemCount: 0, totalQuantity: 0, subtotal: 0, delivery_fee: 0, total: 0 }
		summary = null
	},
}
