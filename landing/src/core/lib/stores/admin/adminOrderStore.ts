import type { Order } from '../../types'

let orders: Order[] = []

export const adminOrderStore = {
	getOrders: () => orders,
	setOrders: (nextOrders: Order[]) => { orders = nextOrders },
	clear: () => { orders = [] },
}