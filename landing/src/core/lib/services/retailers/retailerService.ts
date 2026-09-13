import { getOrder, listOrders } from '../orders/orderService'
import { listProducts } from '../products/productService'
import type { Order, Product } from '../../types'
import type { RetailerDashboardData, RetailerDashboardSummary, RetailerInvoice, RetailerSupplier } from '../../types'

export function listRetailerOrders(): Promise<Order[]> { return listOrders() }
export function getRetailerOrder(uuid: string): Promise<Order> { return getOrder(uuid) }
export async function listRetailerProducts(): Promise<Product[]> {
	const response = await listProducts({ page_size: 100 })
	return response.results ?? []
}

export function deriveRetailerSuppliers(products: Product[]): RetailerSupplier[] {
	return products.reduce<RetailerSupplier[]>((suppliers, product) => {
		const name = product.farmer_name || 'Verified Mambonami supplier'
		const existing = suppliers.find((supplier) => supplier.name === name)
		if (existing) existing.products += 1
		else suppliers.push({ name, phone: product.farmer_phone || 'Contact through Mambonami', products: 1, location: 'Kenya' })
		return suppliers
	}, [])
}

export function deriveRetailerInvoices(orders: Order[]): RetailerInvoice[] {
	return orders.map((order) => ({
		id: order.uuid,
		orderUuid: order.uuid,
		invoiceNumber: order.account_number || order.uuid.slice(0, 8),
		issuedAt: order.created_at,
		amount: order.total_amount,
		status: order.status,
	}))
}

export async function getRetailerDashboardData(): Promise<RetailerDashboardData> {
	const [orders, products] = await Promise.all([listOrders(), listRetailerProducts()])
	return { orders, products, suppliers: deriveRetailerSuppliers(products), invoices: deriveRetailerInvoices(orders) }
}

export function summarizeRetailerDashboard(data: RetailerDashboardData): RetailerDashboardSummary {
	return {
		purchaseTotal: data.orders.reduce((total, order) => total + Number(order.total_amount || 0), 0),
		openOrderCount: data.orders.filter((order) => !['delivered', 'cancelled'].includes(String(order.status).toLowerCase())).length,
		supplierCount: data.suppliers.length,
		productCount: data.products.length,
	}
}
