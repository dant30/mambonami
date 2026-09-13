import { confirmFarmerSubOrder, getFarmerSubOrder as getSubOrder, listFarmerSubOrders, markFarmerSubOrderReady } from '../orders/orderService'
import { listPayouts, getPayoutSummary } from '../payouts/payoutService'
import { createFarmerProduct, deleteFarmerProduct, listFarmerProducts, updateFarmerProduct } from '../products/productService'
import type { ProductCreateInput, Product, Order, Payout, PayoutSummary, SubOrder } from '../../types'
import type { FarmerDashboardData, FarmerDashboardSummary, FarmerOrderActionResponse } from '../../types'
import { listOrders } from '../orders/orderService'

export function listFarmerProductsForWorkspace(): Promise<Product[]> {
	return listFarmerProducts()
}

export function createFarmerWorkspaceProduct(input: ProductCreateInput): Promise<Product> {
	return createFarmerProduct(input)
}

export function updateFarmerWorkspaceProduct(uuid: string, input: ProductCreateInput): Promise<Product> {
	return updateFarmerProduct(uuid, input)
}

export function deleteFarmerWorkspaceProduct(uuid: string): Promise<void> {
	return deleteFarmerProduct(uuid)
}

export function listFarmerOrders(): Promise<Order[]> {
	return listOrders()
}

export function listFarmerSubOrdersForWorkspace(): Promise<SubOrder[]> {
	return listFarmerSubOrders()
}

export function getFarmerWorkspaceSubOrder(id: number): Promise<SubOrder> {
	return getSubOrder(id)
}

export function confirmFarmerOrder(id: number, action: 'confirm' | 'reject'): Promise<FarmerOrderActionResponse> {
	return confirmFarmerSubOrder(id, action)
}

export function markFarmerOrderReady(id: number): Promise<FarmerOrderActionResponse> {
	return markFarmerSubOrderReady(id)
}

export function listFarmerPayouts(): Promise<Payout[]> {
	return listPayouts()
}

export function getFarmerPayoutSummary(): Promise<PayoutSummary> {
	return getPayoutSummary()
}

export async function getFarmerDashboardData(): Promise<FarmerDashboardData> {
	const [products, orders, subOrders, payouts, payoutSummary] = await Promise.all([
		listFarmerProducts(),
		listOrders(),
		listFarmerSubOrders(),
		listPayouts(),
		getPayoutSummary(),
	])
	return { products, orders, subOrders, payouts, payoutSummary }
}

export function summarizeFarmerDashboard(data: FarmerDashboardData): FarmerDashboardSummary {
	return {
		activeProductCount: data.products.filter((product) => product.is_active !== false && Number(product.available_quantity) > 0).length,
		pendingOrderCount: data.orders.filter((order) => !['delivered', 'cancelled'].includes(order.status)).length,
		completedSales: Number(data.payoutSummary?.completed_payout_amount ?? 0),
		totalProductCount: data.products.length,
		pendingPayout: Number(data.payoutSummary?.pending_payout_amount ?? 0),
		paidOut: Number(data.payoutSummary?.completed_payout_amount ?? 0),
	}
}
