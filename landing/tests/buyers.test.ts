import { beforeEach, describe, expect, it } from 'vitest'

import { summarizeBuyerDashboard } from '../src/core/lib/services/buyers/buyerService'
import { buyerStore } from '../src/core/lib/stores/buyers/buyerStore'
import type { BuyerDashboardData } from '../src/core/lib/types/buyers/buyer'

const data: BuyerDashboardData = {
	orders: [
		{ id: 1, uuid: 'open', buyer: 1, total_amount: 900, delivery_fee: 0, platform_commission: 0, discount_amount: 0, status: 'paid_escrow', sub_orders: [], scheduled_date: '2026-09-11', scheduled_time_window: '09:00-12:00', created_at: '2026-09-11' },
		{ id: 2, uuid: 'done', buyer: 1, total_amount: 400, delivery_fee: 0, platform_commission: 0, discount_amount: 0, status: 'delivered', sub_orders: [], scheduled_date: '2026-09-10', scheduled_time_window: '09:00-12:00', created_at: '2026-09-10' },
	],
	activeOrder: null,
	wishlist: [],
	cart: [{ product_uuid: 'tomatoes', quantity: 2, unit_price: 45 }],
	cartSummary: { itemCount: 1, totalQuantity: 2, subtotal: 90, delivery_fee: 0, total: 90 },
}

describe('buyer library', () => {
	beforeEach(() => buyerStore.clear())

	it('summarizes open orders and cart totals', () => {
		expect(summarizeBuyerDashboard(data)).toEqual({ openOrderCount: 1, wishlistCount: 0, cartItemCount: 2, cartTotal: 90 })
	})

	it('stores and clears the buyer dashboard snapshot', () => {
		const summary = summarizeBuyerDashboard(data)
		buyerStore.setDashboardData(data, summary)
		expect(buyerStore.getOrders()).toHaveLength(2)
		expect(buyerStore.getCartSummary().total).toBe(90)
		buyerStore.clear()
		expect(buyerStore.getOrders()).toEqual([])
		expect(buyerStore.getSummary()).toBeNull()
	})
})
