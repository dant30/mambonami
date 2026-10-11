import { adminStore } from './adminStore'

export const adminOrderStore = {
	getOrders: adminStore.getOrders,
	setOrders: adminStore.setOrders,
	clear: () => adminStore.setOrders([]),
}