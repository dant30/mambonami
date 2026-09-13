import type { Order } from '../orders'
import type { Product } from '../products'

export interface RetailerSupplier {
	name: string
	phone: string
	products: number
	location: string
}

export interface RetailerInvoice {
	id: string
	orderUuid: string
	invoiceNumber: string
	issuedAt?: string
	amount: string | number
	status: string
}

export interface RetailerDashboardData {
	orders: Order[]
	products: Product[]
	suppliers: RetailerSupplier[]
	invoices: RetailerInvoice[]
}

export interface RetailerDashboardSummary {
	purchaseTotal: number
	openOrderCount: number
	supplierCount: number
	productCount: number
}
