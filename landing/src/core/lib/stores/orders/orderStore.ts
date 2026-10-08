import { localStorageStore } from '../../../storage'
import type { CartItem, CartItemInput, Order } from '../../types'

const CART_STORAGE_KEY = 'orders_cart'

let cachedOrders: Order[] = []
let activeOrder: Order | null = null
let cachedCart: CartItem[] = localStorageStore.get<CartItem[]>(CART_STORAGE_KEY) ?? []
const cartListeners = new Set<() => void>()

function notifyCartListeners() {
	cartListeners.forEach((listener) => listener())
}

function persistCart(items: CartItem[]) {
	cachedCart = items
	localStorageStore.set(CART_STORAGE_KEY, items)
	notifyCartListeners()
}

function normalizeCartItem(item: CartItemInput | CartItem): CartItem {
	const quantity = Number(item.quantity)
	const itemId = 'id' in item ? item.id ?? item.product_uuid : item.product_uuid
	const itemTotalPrice = 'total_price' in item && item.total_price !== undefined ? item.total_price : item.unit_price ?? 0

	return {
		id: itemId,
		product_uuid: item.product_uuid,
		quantity: Number.isFinite(quantity) && quantity > 0 ? quantity : 0,
		unit_price: item.unit_price ?? 0,
		total_price: itemTotalPrice,
		product_detail: item.product_detail,
	}
}

export const orderStore = {
	getOrders: () => cachedOrders,
	setOrders: (orders: Order[]) => { cachedOrders = orders },
	getActiveOrder: () => activeOrder,
	setActiveOrder: (order: Order | null) => { activeOrder = order },
	getCart: () => cachedCart,
	getCartItemCount: () => cachedCart.reduce((total, item) => total + (Number(item.quantity) || 0), 0),
	subscribeToCart: (listener: () => void) => {
		cartListeners.add(listener)
		return () => cartListeners.delete(listener)
	},
	refreshCartFromStorage: () => {
		cachedCart = localStorageStore.get<CartItem[]>(CART_STORAGE_KEY) ?? []
		notifyCartListeners()
	},
	setCart: (items: CartItem[]) => {
		const normalizedItems = items
			.filter((item) => Number(item.quantity) > 0)
			.map((item) => normalizeCartItem(item))

		persistCart(normalizedItems)
	},
	addCartItem: (item: CartItemInput) => {
		const normalizedItem = normalizeCartItem({
			...item,
			product_detail: item.product_detail,
			id: item.product_uuid,
			total_price: item.unit_price ?? 0,
		})
		const existingIndex = cachedCart.findIndex((cartItem) => cartItem.product_uuid === item.product_uuid)

		const nextCart = [...cachedCart]
		if (existingIndex >= 0) {
			const prevItem = nextCart[existingIndex]
			const quantity = Number(prevItem.quantity) + Number(normalizedItem.quantity)
			nextCart[existingIndex] = {
				...prevItem,
				...normalizedItem,
				quantity,
			}
		} else {
			nextCart.push(normalizedItem)
		}

		persistCart(nextCart)
		return nextCart
	},
	updateCartItem: (product_uuid: string, quantity: string | number) => {
		const nextCart = cachedCart
			.map((item) => {
				if (item.product_uuid !== product_uuid) return item
				const normalizedQuantity = Number(quantity)
				return {
					...item,
					quantity: Number.isFinite(normalizedQuantity) && normalizedQuantity > 0 ? normalizedQuantity : 0,
				}
			})
			.filter((item) => Number(item.quantity) > 0)

		persistCart(nextCart)
		return nextCart
	},
	removeCartItem: (product_uuid: string) => {
		const nextCart = cachedCart.filter((item) => item.product_uuid !== product_uuid)
		persistCart(nextCart)
		return nextCart
	},
	clearCart: () => {
		persistCart([])
		return []
	},
	clear: () => {
		cachedOrders = []
		activeOrder = null
		persistCart([])
	},
}