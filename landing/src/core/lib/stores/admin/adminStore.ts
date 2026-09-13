import type { Dispute, Order, Payout } from '../../types'
import type { AdminAuditLog, AdminFarmer, AdminTransportProvider, AdminUser } from '../../types'

let users: AdminUser[] = []
let farmers: AdminFarmer[] = []
let transportProviders: AdminTransportProvider[] = []
let disputes: Dispute[] = []
let payouts: Payout[] = []
let auditLogs: AdminAuditLog[] = []
let orders: Order[] = []

export const adminStore = {
	getUsers: () => users,
	setUsers: (next: AdminUser[]) => { users = next },
	getFarmers: () => farmers,
	setFarmers: (next: AdminFarmer[]) => { farmers = next },
	getTransportProviders: () => transportProviders,
	setTransportProviders: (next: AdminTransportProvider[]) => { transportProviders = next },
	getDisputes: () => disputes,
	setDisputes: (next: Dispute[]) => { disputes = next },
	getPayouts: () => payouts,
	setPayouts: (next: Payout[]) => { payouts = next },
	getAuditLogs: () => auditLogs,
	setAuditLogs: (next: AdminAuditLog[]) => { auditLogs = next },
	getOrders: () => orders,
	setOrders: (next: Order[]) => { orders = next },
	clear: () => {
		users = []
		farmers = []
		transportProviders = []
		disputes = []
		payouts = []
		auditLogs = []
		orders = []
	},
}
