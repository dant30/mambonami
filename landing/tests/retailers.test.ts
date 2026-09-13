import { beforeEach, describe, expect, it } from 'vitest'

import { deriveRetailerInvoices, deriveRetailerSuppliers, summarizeRetailerDashboard } from '../src/core/lib/services/retailers/retailerService'
import { retailerStore } from '../src/core/lib/stores/retailers/retailerStore'
import type { RetailerDashboardData } from '../src/core/lib/types/retailers/retailer'
import type { Order } from '../src/core/lib/types/orders'

const products = [
	{ id: 1, uuid: 'tomatoes', sku: 'T-1', name: 'Tomatoes', price_per_unit: 45, available_quantity: 10, unit: 'kg', farmer_name: 'Green Farm', farmer_phone: '+254700000001' },
	{ id: 2, uuid: 'onions', sku: 'O-1', name: 'Onions', price_per_unit: 30, available_quantity: 10, unit: 'kg', farmer_name: 'Green Farm', farmer_phone: '+254700000001' },
] as const

const orders: Order[] = [{ id: 1, uuid: 'order-1', buyer: 1, account_number: 'ORD-1', total_amount: 900, delivery_fee: 0, platform_commission: 0, discount_amount: 0, status: 'paid_escrow', sub_orders: [], scheduled_date: '2026-09-11', scheduled_time_window: '09:00-12:00', created_at: '2026-09-11' }]

describe('retailer library', () => {
	beforeEach(() => retailerStore.clear())

	it('derives supplier and invoice projections from shared marketplace data', () => {
		const suppliers = deriveRetailerSuppliers([...products])
		const invoices = deriveRetailerInvoices([...orders])
		expect(suppliers).toEqual([{ name: 'Green Farm', phone: '+254700000001', products: 2, location: 'Kenya' }])
		expect(invoices[0]).toMatchObject({ invoiceNumber: 'ORD-1', amount: 900, orderUuid: 'order-1' })
	})

	it('summarizes procurement and clears retailer state', () => {
		const data: RetailerDashboardData = { orders: [...orders], products: [...products], suppliers: deriveRetailerSuppliers([...products]), invoices: deriveRetailerInvoices([...orders]) }
		const summary = summarizeRetailerDashboard(data)
		expect(summary).toEqual({ purchaseTotal: 900, openOrderCount: 1, supplierCount: 1, productCount: 2 })
		retailerStore.setDashboardData(data, summary)
		expect(retailerStore.getSummary()).toEqual(summary)
		retailerStore.clear()
		expect(retailerStore.getOrders()).toEqual([])
		expect(retailerStore.getSummary()).toBeNull()
	})
})
