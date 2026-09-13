import { getActiveOrder, getCart, getCartSummary, getOrder, listOrders, addToCart, clearCart, removeFromCart, updateCartItem } from '../orders/orderService'
import { addToWishlist, listWishlist, removeFromWishlist } from '../products/productService'
import type { CartItem, CartItemInput, CartSummary, Order, WishlistItem } from '../../types'
import type { BuyerDashboardData, BuyerDashboardSummary } from '../../types'

export function listBuyerOrders(): Promise<Order[]> { return listOrders() }
export function getBuyerOrder(uuid: string): Promise<Order> { return getOrder(uuid) }
export function getBuyerActiveOrder(): Promise<Order | null> { return getActiveOrder() }
export function listBuyerWishlist(): Promise<WishlistItem[]> { return listWishlist() }
export function saveBuyerProduct(uuid: string): Promise<WishlistItem> { return addToWishlist(uuid) }
export function removeBuyerSavedProduct(uuid: string): Promise<void> { return removeFromWishlist(uuid) }
export function getBuyerCart(): CartItem[] { return getCart() }
export function getBuyerCartSummary(items?: CartItem[]): CartSummary { return getCartSummary(items) }
export function addBuyerCartItem(item: CartItemInput): CartItem[] { return addToCart(item) }
export function updateBuyerCartItem(uuid: string, quantity: string | number): CartItem[] { return updateCartItem(uuid, quantity) }
export function removeBuyerCartItem(uuid: string): CartItem[] { return removeFromCart(uuid) }
export function clearBuyerCart(): CartItem[] { return clearCart() }

export async function getBuyerDashboardData(): Promise<BuyerDashboardData> {
	const [orders, activeOrder, wishlist] = await Promise.all([listOrders(), getActiveOrder(), listWishlist()])
	const cart = getCart()
	return { orders, activeOrder, wishlist, cart, cartSummary: getCartSummary(cart) }
}

export function summarizeBuyerDashboard(data: BuyerDashboardData): BuyerDashboardSummary {
	return {
		openOrderCount: data.orders.filter((order) => !['delivered', 'cancelled'].includes(String(order.status).toLowerCase())).length,
		wishlistCount: data.wishlist.length,
		cartItemCount: data.cartSummary.totalQuantity,
		cartTotal: data.cartSummary.total,
	}
}
