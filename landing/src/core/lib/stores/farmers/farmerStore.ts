import type { FarmerDashboardData, FarmerDashboardSummary } from '../../types'
import type { Order, Payout, PayoutSummary, Product, SubOrder } from '../../types'

let products: Product[] = []
let orders: Order[] = []
let subOrders: SubOrder[] = []
let payouts: Payout[] = []
let payoutSummary: PayoutSummary | null = null
let summary: FarmerDashboardSummary | null = null

export const farmerStore = {
	getProducts: () => products,
	setProducts: (next: Product[]) => { products = next },
	getOrders: () => orders,
	setOrders: (next: Order[]) => { orders = next },
	getSubOrders: () => subOrders,
	setSubOrders: (next: SubOrder[]) => { subOrders = next },
	getPayouts: () => payouts,
	setPayouts: (next: Payout[]) => { payouts = next },
	getPayoutSummary: () => payoutSummary,
	setPayoutSummary: (next: PayoutSummary | null) => { payoutSummary = next },
	getSummary: () => summary,
	setSummary: (next: FarmerDashboardSummary | null) => { summary = next },
	setDashboardData: (data: FarmerDashboardData, nextSummary: FarmerDashboardSummary) => {
		products = data.products
		orders = data.orders
		subOrders = data.subOrders
		payouts = data.payouts
		payoutSummary = data.payoutSummary
		summary = nextSummary
	},
	clear: () => {
		products = []
		orders = []
		subOrders = []
		payouts = []
		payoutSummary = null
		summary = null
	},
}
