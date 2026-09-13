import { beforeEach, describe, expect, it } from 'vitest'

import { summarizeFarmerDashboard } from '../src/core/lib/services/farmers/farmerService'
import { farmerStore } from '../src/core/lib/stores/farmers/farmerStore'
import type { FarmerDashboardData } from '../src/core/lib/types/farmers/farmer'

const data: FarmerDashboardData = {
	products: [
		{ id: 1, uuid: 'active', sku: 'A', name: 'Tomatoes', price_per_unit: 45, available_quantity: 10, unit: 'kg', is_active: true },
		{ id: 2, uuid: 'empty', sku: 'B', name: 'Onions', price_per_unit: 30, available_quantity: 0, unit: 'kg', is_active: true },
	],
	orders: [
		{ id: 1, uuid: 'order-1', buyer: 1, total_amount: 100, delivery_fee: 0, platform_commission: 0, discount_amount: 0, status: 'paid_escrow', sub_orders: [], scheduled_date: '2026-09-11', scheduled_time_window: '09:00-12:00', created_at: '2026-09-11' },
	],
	subOrders: [],
	payouts: [],
	payoutSummary: { total_payout_amount: 1000, completed_payout_amount: 750, pending_payout_amount: 250, today_payout_amount: 100, completed_payout_count: 1, pending_payout_count: 1 },
}

describe('farmer library', () => {
	beforeEach(() => farmerStore.clear())

	it('summarizes farmer dashboard metrics from workspace data', () => {
		expect(summarizeFarmerDashboard(data)).toEqual({ activeProductCount: 1, pendingOrderCount: 1, completedSales: 750, totalProductCount: 2 })
	})

	it('stores and clears the complete farmer workspace snapshot', () => {
		const summary = summarizeFarmerDashboard(data)
		farmerStore.setDashboardData(data, summary)
		expect(farmerStore.getProducts()).toHaveLength(2)
		expect(farmerStore.getSummary()).toEqual(summary)
		farmerStore.clear()
		expect(farmerStore.getProducts()).toEqual([])
		expect(farmerStore.getSummary()).toBeNull()
	})
})
