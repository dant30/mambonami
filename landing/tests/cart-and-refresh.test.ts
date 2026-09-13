import { beforeEach, describe, expect, it, vi } from 'vitest'

import { apiClient, apiRequest } from '../src/core/api/apiClient'
import { createOrder } from '../src/core/lib/services/orders/orderService'
import { orderStore } from '../src/core/lib/stores/orders/orderStore'

const cartItem = {
	product_uuid: 'tomatoes-1',
	quantity: 2,
	unit_price: 45,
}

function jsonResponse(body: unknown, status = 200) {
	return new Response(JSON.stringify(body), {
	status,
	headers: { 'Content-Type': 'application/json' },
	})
}

describe('cart persistence and checkout', () => {
	beforeEach(() => {
		orderStore.clear()
	})

	it('merges duplicate products and persists quantity changes', () => {
		orderStore.addCartItem(cartItem)
		orderStore.addCartItem({ ...cartItem, quantity: 3 })
		orderStore.updateCartItem(cartItem.product_uuid, 4)

		expect(orderStore.getCart()[0]?.quantity).toBe(4)
		expect(JSON.parse(window.localStorage.getItem('orders_cart') ?? '[]')[0].quantity).toBe(4)
	})

	it('clears the persisted cart only after order creation succeeds', async () => {
		orderStore.addCartItem(cartItem)
		const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ uuid: 'order-1' })

		await createOrder({ items: [{ product_uuid: cartItem.product_uuid, quantity: 2 }], delivery_lat: 0, delivery_lng: 0, scheduled_date: '2026-09-11', scheduled_time_window: '09:00-12:00' })

		expect(orderStore.getCart()).toEqual([])
		expect(post).toHaveBeenCalledOnce()
	})

	it('keeps the cart when order creation fails', async () => {
		orderStore.addCartItem(cartItem)
		vi.spyOn(apiClient, 'post').mockRejectedValue(new Error('offline'))

		await expect(createOrder({ items: [{ product_uuid: cartItem.product_uuid, quantity: 2 }], delivery_lat: 0, delivery_lng: 0, scheduled_date: '2026-09-11', scheduled_time_window: '09:00-12:00' })).rejects.toThrow('offline')
		expect(orderStore.getCart()).toHaveLength(1)
	})
})

describe('token refresh', () => {
	beforeEach(() => {
		apiClient.setAccessToken('expired-token')
	})

	it('refreshes once for concurrent unauthorized requests and retries both', async () => {
		let unauthorizedRequests = 0
		let refreshRequests = 0
		vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
			const url = String(input)
			if (url.includes('/api/token/refresh/')) {
				refreshRequests += 1
				return jsonResponse({ access: 'fresh-token' })
			}
			if (unauthorizedRequests < 2) {
				unauthorizedRequests += 1
				return jsonResponse({ detail: 'expired' }, 401)
			}
			return jsonResponse({ ok: true })
		}))

		await expect(Promise.all([apiRequest('/api/orders/'), apiRequest('/api/products/')])).resolves.toEqual([{ ok: true }, { ok: true }])
		expect(refreshRequests).toBe(1)
	})
})
