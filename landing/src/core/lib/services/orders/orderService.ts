import { apiClient } from '../../../api'
import { ORDER_ENDPOINTS } from '../../../api/endpoints'
import { orderStore } from '../../stores'
import type {
	CartItem,
	CartItemInput,
	CartSummary,
	CreateOrderInput,
	CreateOrderResponse,
	Order,
	OrderListResponse,
	SubOrder,
} from '../../types'

function normalizeOrders(response: OrderListResponse | Order[]): Order[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listOrders(): Promise<Order[]> {
	return normalizeOrders(await apiClient.get<OrderListResponse | Order[]>(ORDER_ENDPOINTS.list))
}

export function getCart(): CartItem[] {
	return orderStore.getCart()
}

export function getCartSummary(items: CartItem[] = getCart(), deliveryFee = 0): CartSummary {
	const normalizedItems = items.filter((item) => Number(item.quantity) > 0)
	const subtotal = normalizedItems.reduce((sum, item) => {
		const unitPrice = Number(item.unit_price ?? item.total_price ?? 0)
		const quantity = Number(item.quantity ?? 0)
		return sum + unitPrice * quantity
	}, 0)

	const itemCount = normalizedItems.length
	const totalQuantity = normalizedItems.reduce((sum, item) => sum + Number(item.quantity ?? 0), 0)

	return {
		itemCount,
		totalQuantity,
		subtotal,
		delivery_fee: Number(deliveryFee) || 0,
		total: subtotal + (Number(deliveryFee) || 0),
	}
}

export function addToCart(item: CartItemInput): CartItem[] {
	return orderStore.addCartItem(item)
}

export function updateCartItem(product_uuid: string, quantity: string | number): CartItem[] {
	return orderStore.updateCartItem(product_uuid, quantity)
}

export function removeFromCart(product_uuid: string): CartItem[] {
	return orderStore.removeCartItem(product_uuid)
}

export function clearCart(): CartItem[] {
	return orderStore.clearCart()
}

export function buildCreateOrderInputFromCart(
	items: CartItem[] | CartItemInput[],
	overrides: Partial<CreateOrderInput> = {},
): CreateOrderInput {
	const normalizedItems = (items ?? []).map((item) => ({
		product_uuid: item.product_uuid,
		quantity: item.quantity,
	}))

	const today = new Date().toISOString().slice(0, 10)

	return {
		delivery_address: overrides.delivery_address ?? '',
		delivery_street: overrides.delivery_street ?? '',
		delivery_city: overrides.delivery_city ?? '',
		delivery_postal_code: overrides.delivery_postal_code ?? '',
		delivery_landmark: overrides.delivery_landmark ?? '',
		delivery_lat: overrides.delivery_lat ?? 0,
		delivery_lng: overrides.delivery_lng ?? 0,
		scheduled_date: overrides.scheduled_date ?? today,
		scheduled_time_window: overrides.scheduled_time_window ?? '09:00-12:00',
		payment_method: overrides.payment_method ?? null,
		promo_code: overrides.promo_code ?? '',
		items: normalizedItems,
	}
}

export function getOrder(uuid: string): Promise<Order> {
	return apiClient.get<Order>(ORDER_ENDPOINTS.detail(uuid))
}

export function getActiveOrder(): Promise<Order | null> {
	return apiClient.get<Order | null>(ORDER_ENDPOINTS.active)
}

export async function createOrder(input: CreateOrderInput): Promise<CreateOrderResponse> {
	const response = await apiClient.post<CreateOrderResponse>(ORDER_ENDPOINTS.create, input)
	orderStore.clearCart()
	return response
}

export async function listFarmerSubOrders(): Promise<SubOrder[]> {
	const response = await apiClient.get<SubOrder[] | { results?: SubOrder[] }>(ORDER_ENDPOINTS.suborders)
	return Array.isArray(response) ? response : response.results ?? []
}

export function getFarmerSubOrder(id: number): Promise<SubOrder> {
	return apiClient.get<SubOrder>(ORDER_ENDPOINTS.suborder(id))
}

export function confirmFarmerSubOrder(id: number, action: 'confirm' | 'reject'): Promise<{ status: string }> {
	return apiClient.post<{ status: string }>(ORDER_ENDPOINTS.confirmSuborder(id), { action })
}

export function markFarmerSubOrderReady(id: number): Promise<{ status: string }> {
	return apiClient.post<{ status: string }>(ORDER_ENDPOINTS.readySuborder(id))
}

export function generateDeliveryOtp(uuid: string): Promise<{ message: string }> {
	return apiClient.post<{ message: string }>(ORDER_ENDPOINTS.generateOtp(uuid))
}

export function verifyDeliveryOtp(uuid: string, otp: string, photo: File): Promise<{ status: string }> {
	const body = new FormData()
	body.append('otp', otp)
	body.append('photo', photo)
	return apiClient.post<{ status: string }>(ORDER_ENDPOINTS.verifyOtp(uuid), body)
}