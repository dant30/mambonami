import { apiClient } from '../../../api'
import { ADMIN_ENDPOINTS } from '../../../api/endpoints'
import type { Order, OrderStatus } from '../../types/orders'

function list<T>(response: T[] | { results?: T[] }): T[] {
	return Array.isArray(response) ? response : response.results ?? []
}

export async function listAdminOrders(): Promise<Order[]> {
	return list(await apiClient.get<Order[] | { results?: Order[] }>(ADMIN_ENDPOINTS.orders.list))
}

export function getAdminOrder(uuid: string): Promise<Order> {
	return apiClient.get<Order>(ADMIN_ENDPOINTS.orders.detail(uuid))
}

export function updateAdminOrderStatus(uuid: string, status: OrderStatus): Promise<Order> {
	return apiClient.post<Order>(ADMIN_ENDPOINTS.orders.status(uuid), { status })
}