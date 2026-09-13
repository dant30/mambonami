import type { Order, SubOrder } from '../orders'
import type { Payout, PayoutSummary } from '../payouts'
import type { Product } from '../products'

export type FarmerOrder = SubOrder

export interface FarmerDashboardData {
	products: Product[]
	orders: Order[]
	subOrders: FarmerOrder[]
	payouts: Payout[]
	payoutSummary: PayoutSummary | null
}

export interface FarmerDashboardSummary {
	activeProductCount: number
	pendingOrderCount: number
	completedSales: number
	totalProductCount: number
	pendingPayout: number
	paidOut: number
}

export interface FarmerOrderActionResponse {
	status: string
	message?: string
}
