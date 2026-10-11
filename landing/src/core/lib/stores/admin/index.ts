export { adminOrderStore } from './adminOrderStore'
export { adminStore } from './adminStore'

import { adminOrderStore } from './adminOrderStore'
import { adminStore } from './adminStore'

export const adminResourceCaches = {
	dashboard: { get: adminStore.getDashboardData, set: adminStore.setDashboardData },
	orders: { get: adminOrderStore.getOrders, set: adminOrderStore.setOrders },
	products: { get: adminStore.getProducts, set: adminStore.setProducts },
	users: { get: adminStore.getUsers, set: adminStore.setUsers },
	farmers: { get: adminStore.getFarmers, set: adminStore.setFarmers },
	transportProviders: { get: adminStore.getTransportProviders, set: adminStore.setTransportProviders },
	disputes: { get: adminStore.getDisputes, set: adminStore.setDisputes },
	payouts: { get: adminStore.getPayouts, set: adminStore.setPayouts },
	auditLogs: { get: adminStore.getAuditLogs, set: adminStore.setAuditLogs },
} as const