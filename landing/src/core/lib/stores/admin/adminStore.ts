import type { Dispute, Order, Payout, Product } from '../../types'
import type { AdminAuditLog, AdminFarmer, AdminTransportProvider, AdminUser } from '../../types'
import type { AdminDashboardData } from '../../types/admin'

let users: AdminUser[] = []
let staff: AdminUser[] = []
let farmers: AdminFarmer[] = []
let transportProviders: AdminTransportProvider[] = []
let disputes: Dispute[] = []
let payouts: Payout[] = []
let auditLogs: AdminAuditLog[] = []
let orders: Order[] = []
let products: Product[] = []

export const adminStore = {
	getDashboardData: (): AdminDashboardData => ({ orders, users, farmers, transportProviders, disputes, payouts, auditLogs }),
	setDashboardData: (next: AdminDashboardData) => {
		orders = next.orders
		users = next.users
		farmers = next.farmers
		transportProviders = next.transportProviders
		disputes = next.disputes
		payouts = next.payouts
		auditLogs = next.auditLogs
	},
	getUsers: () => users,
	setUsers: (next: AdminUser[]) => { users = next },
	getStaff: () => staff,
	setStaff: (next: AdminUser[]) => { staff = next },
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
	getProducts: () => products,
	setProducts: (next: Product[]) => { products = next },
	clear: () => {
		users = []
		staff = []
		farmers = []
		transportProviders = []
		disputes = []
		payouts = []
		auditLogs = []
		orders = []
		products = []
	},
}
