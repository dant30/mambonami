import type { Order, Product } from '../../types'
import type { RetailerDashboardData, RetailerDashboardSummary, RetailerInvoice, RetailerSupplier } from '../../types'

let orders: Order[] = []
let products: Product[] = []
let suppliers: RetailerSupplier[] = []
let invoices: RetailerInvoice[] = []
let summary: RetailerDashboardSummary | null = null

export const retailerStore = {
	getOrders: () => orders,
	setOrders: (next: Order[]) => { orders = next },
	getProducts: () => products,
	setProducts: (next: Product[]) => { products = next },
	getSuppliers: () => suppliers,
	setSuppliers: (next: RetailerSupplier[]) => { suppliers = next },
	getInvoices: () => invoices,
	setInvoices: (next: RetailerInvoice[]) => { invoices = next },
	getSummary: () => summary,
	setSummary: (next: RetailerDashboardSummary | null) => { summary = next },
	setDashboardData: (data: RetailerDashboardData, nextSummary: RetailerDashboardSummary) => {
		orders = data.orders
		products = data.products
		suppliers = data.suppliers
		invoices = data.invoices
		summary = nextSummary
	},
	clear: () => {
		orders = []
		products = []
		suppliers = []
		invoices = []
		summary = null
	},
}
