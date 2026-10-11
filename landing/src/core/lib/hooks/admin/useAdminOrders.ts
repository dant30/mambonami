import { listAdminOrders } from '../../services'
import { adminResourceCaches } from '../../stores'
import type { Order } from '../../types'
import { useAdminResource } from './useAdminResource'

export function useAdminOrders(): {
	orders: Order[]
	isLoading: boolean
	hasError: boolean
} {
	const { data, isLoading, hasError } = useAdminResource(listAdminOrders, adminResourceCaches.orders)

	return { orders: data ?? [], isLoading, hasError }
}